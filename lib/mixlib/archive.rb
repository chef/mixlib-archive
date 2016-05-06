require "mixlib/archive/tar"
require "mixlib/archive/version"

module Mixlib
  class Archive
    attr_reader :extractor

    def initialize(archive, empty: false)
      @empty = empty

      archive = File.expand_path(archive)
      # for now we only support Tar format archives.
      @extractor = Mixlib::Archive::Tar.new(archive)
    end

    def extract(destination)
      create_and_empty(destination)

      extractor.extract(destination)
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
