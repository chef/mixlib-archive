require "ffi-libarchive"

module Mixlib
  class Archive
    class LibArchive
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
        ignore_re = Regexp.union(ignore)
        flags = perms ? ::Archive::EXTRACT_PERM : nil
        Dir.chdir(destination) do
          reader = ::Archive::Reader.open_filename(@archive)

          reader.each_entry do |entry|
            if entry.pathname =~ ignore_re
              Mixlib::Archive::Log.warn "ignoring entry #{entry.pathname}"
              next
            end

            reader.extract(entry, flags.to_i)
          end
          reader.close
        end
      end

      # Creates an archive with the given set of +files+
      #
      # === Parameters
      # gzip<Boolean>:: should the archive be gzipped?
      def create(files, gzip: false)
        compression = gzip ? ::Archive::COMPRESSION_GZIP : ::Archive::COMPRESSION_NONE
        # "PAX restricted" will use PAX extensions when it has to, but will otherwise
        # use ustar for maximum compatibility
        format = ::Archive::FORMAT_TAR_PAX_RESTRICTED

        ::Archive.write_open_filename(archive, compression, format) do |tar|
          files.each do |fn|
            tar.new_entry do |entry|
              entry.pathname = fn
              entry.copy_stat(fn)
              tar.write_header(entry)
              if File.file?(fn)
                content = File.read(fn)
                tar.write_data(content)
              end
            end
          end
        end
      end
    end
  end
end
