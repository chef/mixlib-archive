require "spec_helper"

describe Mixlib::Archive::Tar do
  let(:tar_archive) { "../fixtures/test.tar" }
  let(:tgz_archive) { "../fixtures/test.tgz" }
  let(:tar_gz_archive) { "../fixtures/test.tar.gz" }

  let(:extraction) { lambda { |f| } }

  let(:destination) { Dir.mktmpdir }

  let(:gzip_header) { [0x1F, 0x8B].pack("C*") }

  before do
    allow(IO).to receive(:binread).and_return(nil)
  end

  after do
    FileUtils.remove_entry destination
  end

  describe "#reader" do
    let(:raw) { double(IO, closed?: true, rewind: 0) }

    before do
      allow(Gem::Package::TarReader).to receive(:new).with(raw, &extraction).and_return(true)
      allow_any_instance_of(Mixlib::Archive::Tar).to receive(:is_tar_archive?).and_return(true)
    end

    context "with a gzipped file" do
      before do
        allow(IO).to receive(:binread).and_return(gzip_header)
      end

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

  describe "#create" do
    let(:test_root) { Dir.mktmpdir(nil) }
    let(:archive_path) { File.join(test_root, "test.tar.gz") }
    let(:file_paths) { %w{ . .. fixture_a fixture_b fixture_c fixture_binary } }

    it "creates a tarball" do
      Dir.chdir(fixtures_path) do
        Mixlib::Archive::Tar.new(archive_path).create(file_paths, gzip: true)
      end
      expect(File.file?(archive_path)).to be true
      target = File.join(test_root, "target")
      Mixlib::Archive::LibArchive.new(archive_path).extract(target, ignore: %w{ . .. })
      expect(Dir.entries(target)).to match_array file_paths
      expect(File.size("#{target}/fixture_binary")).to eql 6
    end

  end

  describe "#extract" do
    let(:test_root) { Dir.mktmpdir(nil) }
    let(:archive_path) { File.join(test_root, "malicious.tar") }
    let(:target) { File.join(test_root, "target") }
    let(:outside_path) { File.join(test_root, "pwned") }

    # Builds a tar with a "././@LongLink" header (GNU long-name extension)
    # whose payload is a path-traversal string, followed by a regular entry
    # that would land at that traversed path if unfiltered.
    def write_longlink_tar(archive_path, longlink_target, payload)
      File.open(archive_path, "wb") do |f|
        writer = Gem::Package::TarWriter.new(f)
        header = Gem::Package::TarHeader.new(
          name: Mixlib::Archive::Tar::TAR_LONGLINK,
          typeflag: "L",
          size: longlink_target.bytesize,
          prefix: "",
          mode: 0o644
        ).to_s
        f.write(header)
        f.write(longlink_target.ljust((longlink_target.bytesize / 512.0).ceil * 512, "\x00"))
        writer.add_file_simple("innocent_name.txt", 0o644, payload.bytesize) { |io| io.write(payload) }
        writer.close
      end
    end

    it "does not write outside destination via a @LongLink path traversal payload" do
      write_longlink_tar(archive_path, "../pwned", "pwned!")

      described_class.new(archive_path).extract(target)

      expect(File.exist?(outside_path)).to be false
    end

    it "still extracts entries with legitimate long names" do
      long_name = "a" * 200
      write_longlink_tar(archive_path, long_name, "hello")

      described_class.new(archive_path).extract(target)

      expect(File.read(File.join(target, long_name))).to eq("hello")
    end

    # Builds a tar with a symlink entry pointing outside of the extraction
    # destination, followed by a regular file entry whose path travels
    # "through" that symlink. Without a containment check on symlink targets
    # this is the classic tar-slip attack: the symlink is planted first, then
    # the second entry's write follows it to land anywhere on disk.
    def write_symlink_escape_tar(archive_path, link_name, link_target, file_through_link, payload)
      File.open(archive_path, "wb") do |f|
        writer = Gem::Package::TarWriter.new(f)
        writer.add_symlink(link_name, link_target, 0o777)
        writer.add_file_simple(file_through_link, 0o644, payload.bytesize) { |io| io.write(payload) }
        writer.close
      end
    end

    it "does not create a symlink that escapes destination" do
      write_symlink_escape_tar(archive_path, "link", outside_path, "link/pwned.txt", "pwned!")

      described_class.new(archive_path).extract(target)

      expect(File.symlink?(File.join(target, "link"))).to be false
      expect(File.exist?(outside_path)).to be false
    end

    it "does not write a file outside destination via a symlinked path" do
      FileUtils.mkdir_p(outside_path)
      write_symlink_escape_tar(archive_path, "link", outside_path, "link/pwned.txt", "pwned!")

      described_class.new(archive_path).extract(target)

      expect(File.exist?(File.join(outside_path, "pwned.txt"))).to be false
    end

    it "still allows symlinks that resolve within destination" do
      real_dir = File.join(target, "realdir")
      FileUtils.mkdir_p(real_dir)
      write_symlink_escape_tar(archive_path, "link", real_dir, "link/ok.txt", "hello")

      described_class.new(archive_path).extract(target)

      expect(File.symlink?(File.join(target, "link"))).to be true
      expect(File.read(File.join(target, "realdir", "ok.txt"))).to eq("hello")
    end
  end

  describe "#is_tar_archive?" do
    let(:raw) { double(IO, closed?: true, rewind: 0, read: data) }
    context "oldgnu style header" do
      let(:data) { "testdir/#{Array.new(249) { "\x00" }.join}ustar  \x00" }
      it "identifies an oldgnu style tar header" do
        extractor = described_class.new(tgz_archive)
        expect(extractor.send(:is_tar_archive?, raw)).to eq(true)
      end
    end
    context "gnu style header" do
      let(:data) { "testdir/#{Array.new(249) { "\x00" }.join}ustar\x00" }
      it "identifies an gnu style tar header" do
        extractor = described_class.new(tgz_archive)
        expect(extractor.send(:is_tar_archive?, raw)).to eq(true)
      end
    end
    context "invalid header" do
      let(:data) { "testdir/#{Array.new(249) { "\x00" }.join}notavalidheader" }
      it "does not identify an invalid header" do
        extractor = described_class.new(tgz_archive)
        expect(extractor.send(:is_tar_archive?, raw)).to eq(false)
      end
    end
    context "invalid small file" do
      let(:data) { "testdir/#{Array.new(11) { "\x00" }.join}smallfile" }
      it "does not identify an invalid header in a small file" do
        extractor = described_class.new(tgz_archive)
        expect(extractor.send(:is_tar_archive?, raw)).to eq(false)
      end
    end
  end

end
