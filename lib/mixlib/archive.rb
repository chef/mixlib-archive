require "mixlib/archive/tar"
require "mixlib/archive/version"
require "mixlib/log"

module Mixlib
  class Archive
    attr_reader :archiver
    alias_method :extractor, :archiver

    def initialize(archive, empty: false)
      @empty = empty

      archive = File.expand_path(archive)
      # for now we only support Tar format archives.
      @archiver = Mixlib::Archive::Tar.new(archive)
    end

    class Log
      extend Mixlib::Log
    end

    Log.level = :error

    def create(files = [], gzip: false)
      archiver.create(files, gzip: gzip)
    end

    def extract(destination, perms: true, ignore: [])
      ignore = [/^\.$/, /\.{2}/] + Array(ignore)

      create_and_empty(destination)

      archiver.extract(destination, perms: perms, ignore: ignore)
    end

    private

    def create_and_empty(destination)
      FileUtils.mkdir_p(destination)
      if @empty
        Dir.foreach(destination) do |entry|
          next if entry == "." || entry == ".."
          FileUtils.remove_entry_secure(File.join(destination, entry))
        end
      end
    end

  end
end
