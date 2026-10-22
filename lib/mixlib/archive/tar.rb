require "rubygems/package" unless defined?(Gem::Package)
require "rubygems/package/tar_reader" unless defined?(Gem::Package::TarReader)
require "rubygems/package/tar_writer" unless defined?(Gem::Package::TarWriter)
require "rubygems/package/tar_header" unless defined?(Gem::Package::TarHeader)
require "tempfile" unless defined?(Tempfile)
require "zlib" unless defined?(Zlib)
require_relative "confinement"

module Mixlib
  class Archive
    class Tar
      include Confinement

      TAR_LONGLINK = "././@LongLink".freeze

      attr_reader :options
      attr_reader :archive

      def initialize(archive, options = {})
        @archive = archive
        @options = options
      end

      # Extracts the archive to the given +destination+
      #
      # === Parameters
      # perms<Boolean>:: should the extractor use permissions from the archive.
      # ignore[Array]:: an array of matches of file paths to ignore
      def extract(destination, perms: true, ignore: [])
        # (http://stackoverflow.com/a/31310593/506908)
        ignore_re = Regexp.union(ignore)
        destination_root = File.expand_path(destination)
        FileUtils.mkdir_p(destination_root)
        real_root = File.realpath(destination_root)
        created_links = existing_confined_symlinks(destination_root, real_root)
        reader do |tar|
          dest = nil
          tar.each do |entry|
            if entry.full_name == TAR_LONGLINK
              dest = File.expand_path(File.join(destination, entry.read.strip))
              next
            end
            if entry.full_name =~ ignore_re
              Mixlib::Archive::Log.warn "ignoring entry #{entry.full_name}"
              next
            end
            dest ||= File.expand_path(File.join(destination, entry.full_name))
            # Reject any entry (including @LongLink-derived paths) that resolves
            # outside destination, closing the tar-slip / path traversal bypass.
            unless dest == destination_root || dest.start_with?(destination_root + File::SEPARATOR)
              reject_entry "ignoring entry #{entry.full_name}: resolves outside #{destination}"
              dest = nil
              next
            end
            # The lexical check above does not see symlinks that already exist on
            # disk (pre-existing in destination or planted earlier). Confirm the
            # real location of the parent stays within the real destination.
            unless confined?(File.dirname(dest), real_root)
              reject_entry "ignoring entry #{entry.full_name}: path traverses a symlink resolving outside #{destination}"
              dest = nil
              next
            end

            is_dir = entry.directory? || (entry.header.typeflag == "" && entry.full_name.end_with?("/"))
            is_file = entry.file? || (entry.header.typeflag == "" && !entry.full_name.end_with?("/"))
            is_symlink = entry.header.typeflag == "2"

            unless is_dir || is_file || is_symlink
              # hardlinks, devices, fifos...: none can be extracted safely
              reject_entry "ignoring entry #{entry.full_name}: unsupported tar entry type #{entry.header.typeflag.inspect}"
              dest = nil
              next
            end

            # A directory entry over an existing symlinked directory that stays
            # inside destination is left alone instead of being replaced.
            if is_dir && File.symlink?(dest) && File.directory?(dest) && confined?(dest, real_root)
              dest = nil
              next
            end

            parent = File.dirname(dest)
            FileUtils.mkdir_p(parent) unless File.directory?(parent)

            # Never write through a symlink sitting at the entry's own path;
            # replace it instead so open/chmod/mkdir cannot follow it.
            File.unlink(dest) if File.symlink?(dest)

            if is_dir
              File.delete(dest) if File.file?(dest)

              if perms
                FileUtils.mkdir_p(dest, mode: safe_mode(entry.header.mode), verbose: false)
              else
                FileUtils.mkdir_p(dest, verbose: false)
              end

            elsif is_file
              FileUtils.rm_rf(dest) if File.directory?(dest)
              # NOFOLLOW narrows the window in which a symlink swapped in after
              # the checks above could be followed.
              flags = File::WRONLY | File::CREAT | File::TRUNC | File::BINARY | (defined?(File::NOFOLLOW) ? File::NOFOLLOW : 0)
              File.open(dest, flags, 0o666) do |f|
                IO.copy_stream(entry, f)
              end
              FileUtils.chmod(safe_mode(entry.header.mode), dest, verbose: false) if perms
            else
              # handle symlink
              #
              # The target is resolved against the real filesystem (a lexical
              # check is fooled by ".." after another symlink) and must stay
              # inside destination; a final sweep below catches links whose
              # meaning is changed by a later entry.
              if symlink_target_confined?(dest, entry.header.linkname, real_root)
                File.symlink(entry.header.linkname, dest)
                created_links << dest
              else
                reject_entry "ignoring entry #{entry.full_name}: symlink target #{entry.header.linkname} resolves outside #{destination}"
              end
            end

            dest = nil
          end
        end
        prune_escaping_symlinks(created_links, real_root)
      end

      # Creates an archive with the given set of +files+
      #
      # === Parameters
      # gzip<Boolean>:: should the archive be gzipped?
      def create(files, gzip: false)
        tgt_dir = File.dirname(archive)
        target = Tempfile.new(File.basename(archive), tgt_dir)
        target.binmode

        Gem::Package::TarWriter.new(target) do |tar|
          files.each do |fn|
            mode = File.stat(fn).mode
            if File.symlink?(fn)
              target = File.readlink(fn)
              tar.add_symlink(fn, target, mode)
            elsif File.directory?(fn)
              tar.mkdir(fn, mode)
            elsif File.file?(fn)
              file = File.open(fn, "rb")
              tar.add_file(fn, mode) do |io|
                io.write(file.read)
              end
              file.close
            end
          end
        end

        target.close
        if gzip
          Zlib::GzipWriter.open(archive, Zlib::BEST_COMPRESSION) do |gz|
            gz.mtime = File.mtime(target.path)
            gz.orig_name = File.basename(archive)
            File.open(target.path) do |file|
              while (chunk = file.read(16 * 1024))
                gz.write(chunk)
              end
            end
          end
        else
          FileUtils.mv(target.path, archive)
        end
      ensure
        target.close unless target.closed?
      end

      private

      def is_gzip_file?(path)
        # You cannot write "\x1F\x8B" because the default encoding of
        # ruby >= 1.9.3 is UTF-8 and 8B is an invalid in UTF-8.
        IO.binread(path, 2) == [0x1F, 0x8B].pack("C*")
      end

      # tar's magic is at byte 257 and is "ustar\0"
      # OLDGNU_MAGIC "ustar  \0"  /* 7 chars and a null */
      def is_tar_archive?(io)
        !(read_tar_magic(io) =~ /ustar\s{0,2}\x00/).nil?
      end

      def read_tar_magic(io)
        io.rewind
        magic = Array(io.read(512).bytes[257..264]).pack("C*")
        io.rewind
        magic
      end

      def reader(&block)
        raw = File.open(archive, "rb")

        file = if is_gzip_file?(archive)
                 Mixlib::Archive::Log.debug "gzip file detected"
                 Zlib::GzipReader.wrap(raw)
               else
                 raw
               end

        raise Mixlib::Archive::TarError, "Unrecognized archive format" unless is_tar_archive?(file)

        Gem::Package::TarReader.new(file, &block)
      ensure
        if file
          file.close unless file.closed?
          file = nil # rubocop:disable Lint/UselessAssignment
        end
        if raw
          raw.close unless raw.closed?
          raw = nil # rubocop:disable Lint/UselessAssignment
        end
      end

    end
  end
end
