require "spec_helper"

describe Mixlib::Archive::LibArchive do
  let(:tar_archive) { "#{fixtures_path}/test.tar" }
  let(:tgz_archive) { "#{fixtures_path}/test.tgz" }
  let(:tar_gz_archive) { "#{fixtures_path}/test.tar.gz" }

  let(:extraction) { lambda { |f| } }

  let(:destination) { Dir.mktmpdir }

  let(:gzip_header) { [0x1F, 0x8B].pack("C*") }

  before do
    allow(IO).to receive(:binread).and_return(nil)
  end

  after do
    FileUtils.remove_entry destination
  end

  describe "#reader"

  describe "#create" do
    let(:test_root) { Dir.mktmpdir(nil) }
    let(:archive_path) { File.join(test_root, "test.tar.gz") }
    let(:file_paths) { %w{ . .. fixture_a fixture_b fixture_c } }

    context "using the correct options" do
      it "requests the correct tar format" do
        expect(::Archive).to receive(:write_open_filename).with(archive_path, 0, ::Archive::FORMAT_TAR_PAX_RESTRICTED)
        Mixlib::Archive::LibArchive.new(archive_path).create([])
      end

      it "requests gzip compression" do
        expect(::Archive).to receive(:write_open_filename).with(archive_path, ::Archive::COMPRESSION_GZIP, ::Archive::FORMAT_TAR_PAX_RESTRICTED)
        Mixlib::Archive::LibArchive.new(archive_path).create([], gzip: true)
      end

      it "requests no compression" do
        expect(::Archive).to receive(:write_open_filename).with(archive_path, ::Archive::COMPRESSION_NONE, ::Archive::FORMAT_TAR_PAX_RESTRICTED)
        Mixlib::Archive::LibArchive.new(archive_path).create([], gzip: false)
      end
    end

    it "creates a tarball" do
      Dir.chdir(fixtures_path) do
        Mixlib::Archive::LibArchive.new(archive_path).create(file_paths, gzip: true)
      end
      expect(File.file?(archive_path)).to be true
      target = File.join(test_root, "target")
      Mixlib::Archive::LibArchive.new(archive_path).extract(target)
      expect(Dir.entries(target)).to match_array file_paths
    end

  end
end
