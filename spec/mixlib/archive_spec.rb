require "spec_helper"

describe Mixlib::Archive do
  let(:target) { "../fixtures/foo.tar" }
  let (:destination) { Dir.mktmpdir }
  let (:files) { %w{ file dir/file new_file.rb } }

  let (:archive) { described_class.new(target) }
  let (:archiver) { double(Mixlib::Archive::Tar, extract: true) }

  before do
    allow(File).to receive(:expand_path).and_call_original
    allow(Mixlib::Archive::Tar).to receive(:new).with(any_args).and_return(archiver)
  end

  after do
    FileUtils.rmdir destination
  end

  describe "#initialize" do
    it "accepts a path" do
      expect { described_class.new("../foo") }.not_to raise_error
    end

    it "allows the target to be emptied" do
      expect { described_class.new("../foo", empty: true) }.not_to raise_error
    end

    context "creates an archiver" do
      let(:expanded_target) { "/my/expanded/target/fixtures/foo.tar" }
      before do
      end

      it "with the correct archiver" do
        expect(File).to receive(:expand_path).with(target).and_return(expanded_target)
        expect(Mixlib::Archive::Tar).to receive(:new).with(expanded_target)
        described_class.new(target)
      end
    end
  end

  describe "#create" do
    it "runs the archiver" do
      expect(archive).to receive(:create).with(files).and_return(true)
      archive.create(files)
    end

    it "passes options to the archiver" do
      expect(archive).to receive(:create).with(files, { gzip: true }).and_return(true)
      archive.create(files, gzip: true)
    end
  end

  describe "#extract" do
    it "creates the target directory" do
      expect(archive).to receive(:create_and_empty).with(destination).and_return(true)
      archive.extract(destination)
    end

    it "runs the extractor" do
      expect(archiver).to receive(:extract).with(destination, { perms: true, ignore: [/^\.$/, /\.{2}/] })
      archive.extract(destination)
    end

    it "passes options to the extractor" do
      expect(archiver).to receive(:extract).with(destination, { perms: false, ignore: [/^\.$/, /\.{2}/] })
      archive.extract(destination, perms: false)
    end

    it "allows the user to ignore more patterns" do
      expect(archiver).to receive(:extract).with(destination, { perms: false, ignore: [/^\.$/, /\.{2}/, /^$/] })
      archive.extract(destination, perms: false, ignore: [/^$/])
    end

    it "accepts a single ignore pattern" do
      expect(archiver).to receive(:extract).with(destination, { perms: false, ignore: [/^\.$/, /\.{2}/, /^$/] })
      archive.extract(destination, perms: false, ignore: /^$/)
    end
  end

  describe "#create_and_empty" do
    it "creates the target directory" do
      expect(FileUtils).to receive(:mkdir_p).with(destination)
      archive.send(:create_and_empty, destination)
    end

    it "doesn't empty the target directory" do
      expect(Dir).not_to receive(:foreach)
      archive.send(:create_and_empty, destination)
    end

    context "optionally empties the target directory" do
      before do
        archive.instance_variable_set(:@empty, true)
      end

      it "walks the directory" do
        expect(Dir).to receive(:foreach).with(destination)
        archive.send(:create_and_empty, destination)
      end

      it "ignores . and .." do
        expect(Dir).to receive(:foreach).with(destination).and_yield(".").and_yield("..")
        expect(FileUtils).not_to receive(:remove_entry_secure)
        archive.send(:create_and_empty, destination)
      end

      it "deletes the entry" do
        deleted = File.join(destination, "foo")

        expect(Dir).to receive(:foreach).with(destination).and_yield(".").and_yield("..").and_yield("foo")
        expect(FileUtils).to receive(:remove_entry_secure).with(deleted).and_return(true)
        archive.send(:create_and_empty, destination)
      end
    end
  end
end
