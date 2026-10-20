require "spec_helper"
require_relative "shared_hardening_examples"

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
    let(:file_paths) { %w{ . .. fixture_a fixture_b fixture_c fixture_binary } }

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

    shared_examples_for "creates a tarball" do
      it "creates a tarball" do
        Dir.chdir(fixtures_path) do
          Mixlib::Archive::LibArchive.new(archive_path).create(file_paths, gzip: true)
        end
        expect(File.file?(archive_path)).to be true
        Mixlib::Archive::LibArchive.new(archive_path).extract(target, ignore: %w{ . .. })
        expect(Dir.entries(target)).to match_array file_paths
        expect(File.size("#{target}/fixture_binary")).to eql 6
        expect(File.size("#{target}/fixture_a")).to eql 10
        expect(File.size("#{target}/fixture_b")).to eql 10
        expect(File.size("#{target}/fixture_c")).to eql 11 # this specifically tests windows binmode + crlf conversions
        # we test that the file sizes in the originals haven't been changed due to crlf mangling by git itself
        expect(File.size("#{fixtures_path}/fixture_binary")).to eql 6
        expect(File.size("#{fixtures_path}/fixture_a")).to eql 10
        expect(File.size("#{fixtures_path}/fixture_b")).to eql 10
        expect(File.size("#{fixtures_path}/fixture_c")).to eql 11
      end
    end

    context "with a string" do
      let(:target) { File.join(test_root, "target") }

      it_behaves_like "creates a tarball"
    end

    context "with a Pathname" do
      let(:target) { Pathname.new(test_root) + "target" }

      it_behaves_like "creates a tarball"
    end
  end

  describe "hardening" do
    def extract_archive(archive, target)
      described_class.new(archive).extract(target, ignore: [/^\.$/, %r{\.{2}/}])
    end

    # libarchive on Windows cannot create symlinks from archive entries
    def hs_skip_archive_symlinks?
      Gem.win_platform?
    end

    it_behaves_like "a hardened extractor"
  end

  describe "#extract into a destination with a pre-existing symlink" do
    let(:test_root) { Dir.mktmpdir(nil) }
    let(:archive_path) { File.join(test_root, "payload.tar") }
    let(:target) { File.join(test_root, "target") }
    let(:outside_dir) { File.join(test_root, "outside") }
    let(:outside_file) { File.join(outside_dir, "secret.txt") }
    let(:link) { File.join(target, "link") }

    before do
      FileUtils.mkdir_p([target, outside_dir])
      File.write(outside_file, "original")
      begin
        File.symlink(outside_dir, link)
      rescue NotImplementedError, Errno::EACCES, Errno::EPERM
        skip "symlinks not supported in this environment"
      end
    end

    after do
      FileUtils.remove_entry test_root
    end

    def build_tar
      File.open(archive_path, "wb") do |f|
        writer = Gem::Package::TarWriter.new(f)
        yield writer
        writer.close
      end
    end

    it "does not write a new file through the symlinked directory" do
      build_tar { |w| w.add_file_simple("link/pwned.txt", 0o644, 6) { |io| io.write("pwned!") } }

      described_class.new(archive_path).extract(target, ignore: %w{ . .. })

      expect(File.exist?(File.join(outside_dir, "pwned.txt"))).to be false
    end

    it "does not overwrite an existing outside file through the symlinked directory" do
      build_tar { |w| w.add_file_simple("link/secret.txt", 0o644, 6) { |io| io.write("pwned!") } }

      described_class.new(archive_path).extract(target, ignore: %w{ . .. })

      expect(File.read(outside_file)).to eq("original")
    end

    it "does not create directories through the symlinked directory" do
      build_tar { |w| w.mkdir("link/newdir/deeper", 0o755) }

      described_class.new(archive_path).extract(target, ignore: %w{ . .. })

      expect(File.exist?(File.join(outside_dir, "newdir"))).to be false
    end

    it "still extracts entries with absolute paths underneath the destination" do
      skip "libarchive absolute path handling differs on Windows" if Gem.win_platform?
      File.delete(link)
      build_tar { |w| w.add_file_simple("/abs/x.txt", 0o644, 2) { |io| io.write("hi") } }

      described_class.new(archive_path).extract(target, ignore: [/^\.$/, %r{\.{2}/}])

      expect(File.read(File.join(target, "abs", "x.txt"))).to eq("hi")
    end
  end
end
