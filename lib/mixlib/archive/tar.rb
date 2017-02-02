require "rubygems/package"
require "zlib"

module Mixlib
  class Archive
    class Tar
      TAR_LONGLINK = "././@LongLink"

      attr_reader :options
      attr_reader :archive

      def initialize(archive, options = {})
        @archive = archive
        @options = options
      end

      # Extracts the archive to the given +destination+
      #
      # === Parameters
      # perms<Boolean>:: should the extracter use permissions from the archive.
      # ignore[Array]:: an array of matches of file paths to ignore
      def extract(destination, perms: true, ignore: [])
        # (http://stackoverflow.com/a/31310593/506908)
        ignore_re = Regexp.union(ignore)
        reader do |tar|
          dest = nil
          tar.each do |entry|
            if entry.full_name == TAR_LONGLINK
              dest = File.join(destination, entry.read.strip)
              next
            end
            if entry.full_name =~ ignore_re
              Mixlib::Archive::Log.warn "ignoring entry #{entry.full_name}"
              next
            end
            dest ||= File.join(destination, entry.full_name)
            parent = File.dirname(dest)
            FileUtils.mkdir_p(parent)

            if entry.directory? || (entry.header.typeflag == "" && entry.full_name.end_with?("/"))
              File.delete(dest) if File.file?(dest)

              if perms
                FileUtils.mkdir_p(dest, mode: entry.header.mode, verbose: false)
              else
                FileUtils.mkdir_p(dest, verbose: false)
              end

            elsif entry.file? || (entry.header.typeflag == "" && !entry.full_name.end_with?("/"))
              FileUtils.rm_rf(dest) if File.directory?(dest)
              File.open(dest, "wb") do |f|
                f.print(entry.read)
              end
              FileUtils.chmod(entry.header.mode, dest, verbose: false) if perms
            elsif entry.header.typeflag == "2"
              # handle symlink
              File.symlink(entry.header.linkname, dest)
            else
              Mixlib::Archive::Log.warn "unknown tar entry: #{entry.full_name} type: #{entry.header.typeflag}"
            end

            dest = nil
          end
        end
      end

      # Creates an archive with the given set of +files+
      #
      # === Parameters
      # gzip<Boolean>:: should the archive be gzipped?
      def create(files, gzip: false)
        tgt_dir = File.dirname(archive)
        target = Tempfile.new(File.basename(archive), tgt_dir)

        Gem::Package::TarWriter.new(target) do |tar|
          files.each do |fn|
            mode = File.stat(fn).mode
            file = File.open(fn, "rb")
            tar.add_file(fn, mode) do |io|
              io.write(file)
            end
            file.close
          end
        end

        target.close
        if gzip
          Zlib::GzipWriter.open(archive) do |gz|
            gz.mtime = File.mtime(target.path)
            gz.orig_name = File.basename(archive)
            gz.write IO.binread(target.path)
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

      def reader(&block)
        raw = File.open(archive, "rb")

        file = if is_gzip_file?(archive)
                 Mixlib::Archive::Log.debug "gzip file detected"
                 Zlib::GzipReader.wrap(raw)
               else
                 raw
               end

        Gem::Package::TarReader.new(file, &block)
      ensure
        if file
          file.close unless file.closed?
          file = nil
        end
        if raw
          raw.close unless raw.closed?
          raw = nil
        end
      end

    end
  end
end
