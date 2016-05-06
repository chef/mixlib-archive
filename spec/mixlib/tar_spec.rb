require "spec_helper"

describe Mixlib::Archive::Tar do
  let(:tar_archive) { "../fixtures/test.tar" }
  let(:tgz_archive) { "../fixtures/test.tgz" }
  let(:tar_gz_archive) { "../fixtures/test.tar.gz" }

  let(:extraction) { lambda { |f| } }

  let(:destination) { Dir.mktmpdir }

  after do
    FileUtils.remove_entry destination
  end

  describe "#reader" do
    let(:raw) { double(File, closed?: true) }

    before do
      allow(Gem::Package::TarReader).to receive(:new).with(raw, &extraction).and_return(true)
    end

    context "with a gzipped file" do
      it "creates the correct reader for a .tgz file" do
        extractor = described_class.new(tgz_archive)
        expect(File).to receive(:open).with(tgz_archive, "rb").and_return(raw)
        expect(Zlib::GzipReader).to receive(:wrap).with(raw).and_return(raw)
        extractor.send(:reader, &extraction)
      end

      it "creates the correct reader for a .tar.gz file" do
        extractor = described_class.new(tar_gz_archive)
        expect(File).to receive(:open).with(tar_gz_archive, "rb").and_return(raw)
        expect(Zlib::GzipReader).to receive(:wrap).with(raw).and_return(raw)
        extractor.send(:reader, &extraction)
      end
    end

    context "with a regular tar file" do
      let(:extractor) { described_class.new(tar_archive) }

      it "creates the correct reader" do
        expect(File).to receive(:open).with(tar_archive, "rb").and_return(raw)
        extractor.send(:reader, &extraction)
      end
    end

  end
end
