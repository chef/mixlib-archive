require "spec_helper"

# Hardening behaviour that both extractors (Tar and LibArchive) must share.
# The including describe block must define `extract_archive(archive, target)`.
RSpec.shared_examples "a hardened extractor" do
  let(:hs_root) { Dir.mktmpdir(nil) }
  let(:hs_archive) { File.join(hs_root, "payload.tar") }
  let(:hs_target) { File.join(hs_root, "target") }
  let(:hs_outside) { File.join(hs_root, "outside") }
  let(:hs_secret) { File.join(hs_outside, "secret.txt") }

  before do
    FileUtils.mkdir_p([hs_target, hs_outside])
    File.write(hs_secret, "original")
  end

  after do
    FileUtils.remove_entry hs_root
  end

  def hs_header(name, type, mode: 0o644, linkname: "", major: 0, minor: 0)
    Gem::Package::TarHeader.new(name: name, size: 0, mode: mode, typeflag: type, linkname: linkname,
      prefix: "", uid: 0, gid: 0, mtime: 0, checksum: 0, devmajor: major, devminor: minor,
      magic: "ustar", version: "00", uname: "", gname: "").to_s
  end

  def hs_build
    File.open(hs_archive, "wb") do |f|
      writer = Gem::Package::TarWriter.new(f)
      yield writer, f
      writer.close
    end
  end

  def hs_symlinks_supported!
    skip "extractor cannot create archive symlinks on this platform" if respond_to?(:hs_skip_archive_symlinks?) && hs_skip_archive_symlinks?
    probe = File.join(hs_root, "probe_link")
    File.symlink(hs_outside, probe)
    File.delete(probe)
  rescue NotImplementedError, Errno::EACCES, Errno::EPERM
    skip "symlinks not supported in this environment"
  end

  it "strips setuid and setgid bits from extracted files" do
    skip "mode bits are not meaningful on Windows" if Gem.win_platform?
    hs_build { |w| w.add_file_simple("suid", 0o6755, 2) { |io| io.write("hi") } }

    extract_archive(hs_archive, hs_target)

    expect(File.stat(File.join(hs_target, "suid")).mode & 0o6000).to eq(0)
    expect(File.read(File.join(hs_target, "suid"))).to eq("hi")
  end

  it "strips setuid and setgid bits from extracted directories" do
    skip "mode bits are not meaningful on Windows" if Gem.win_platform?
    hs_build { |w| w.mkdir("dir", 0o6755) }

    extract_archive(hs_archive, hs_target)

    expect(File.stat(File.join(hs_target, "dir")).mode & 0o6000).to eq(0)
  end

  it "does not create hardlinks to files outside the destination" do
    skip "hardlinks not meaningful on Windows" if Gem.win_platform?
    hs_build { |_w, f| f.write(hs_header("hl", "1", linkname: hs_secret)) }

    extract_archive(hs_archive, hs_target)

    expect(File.exist?(File.join(hs_target, "hl"))).to be false
    expect(File.stat(hs_secret).nlink).to eq(1)
  end

  it "does not create fifos" do
    skip "fifos not meaningful on Windows" if Gem.win_platform?
    hs_build { |_w, f| f.write(hs_header("fifo", "6")) }

    extract_archive(hs_archive, hs_target)

    expect(File.exist?(File.join(hs_target, "fifo"))).to be false
  end

  it "does not create device nodes" do
    skip "devices not meaningful on Windows" if Gem.win_platform?
    hs_build { |_w, f| f.write(hs_header("blk", "4", mode: 0o666, major: 8, minor: 0)) }

    extract_archive(hs_archive, hs_target)

    expect(File.exist?(File.join(hs_target, "blk"))).to be false
  end

  it "does not create an absolute symlink pointing outside the destination" do
    hs_symlinks_supported!
    hs_build { |w| w.add_symlink("evil", hs_secret, 0o777) }

    extract_archive(hs_archive, hs_target)

    expect(File.symlink?(File.join(hs_target, "evil"))).to be false
  end

  {
    "up" => "..",
    "up_slash" => "../",
    "up_sibling" => "../outside",
    "d/up_two" => "../..",
    "d/up_deep" => "../../outside/secret.txt",
  }.each do |name, linkname|
    it "does not create symlink #{name} -> #{linkname} that reaches the destination's parent or above" do
      hs_symlinks_supported!
      hs_build do |w|
        w.mkdir("d", 0o755)
        w.add_symlink(name, linkname, 0o777)
      end

      extract_archive(hs_archive, hs_target)

      expect(File.symlink?(File.join(hs_target, name))).to be false
    end
  end

  it "does not create an absolute symlink to the destination's parent directory" do
    hs_symlinks_supported!
    hs_build { |w| w.add_symlink("up_abs", hs_root, 0o777) }

    extract_archive(hs_archive, hs_target)

    expect(File.symlink?(File.join(hs_target, "up_abs"))).to be false
  end

  it "allows a symlink whose '..' stays inside the destination" do
    hs_symlinks_supported!
    hs_build do |w|
      w.mkdir("d", 0o755)
      w.add_symlink("d/up_one", "..", 0o777) # d/.. is the destination itself
    end

    extract_archive(hs_archive, hs_target)

    expect(File.symlink?(File.join(hs_target, "d", "up_one"))).to be true
  end

  it "does not create a symlink whose '..' after another symlink escapes the destination" do
    hs_symlinks_supported!
    hs_build do |w|
      w.mkdir("a", 0o755)
      w.mkdir("a/b", 0o755)
      w.add_symlink("a/b/s", "../..", 0o777)
      w.add_symlink("T", "a/b/s/..", 0o777)
      w.add_file_simple("T/pwned.txt", 0o644, 6) { |io| io.write("pwned!") }
    end

    extract_archive(hs_archive, hs_target)

    expect(File.symlink?(File.join(hs_target, "T"))).to be false
    expect(Dir.children(hs_root).sort).to eq(%w{outside payload.tar target})
    expect(Dir.children(hs_outside)).to eq(["secret.txt"])
  end

  it "removes a symlink whose target only escapes because of a later entry" do
    hs_symlinks_supported!
    hs_build do |w|
      w.add_symlink("T", "x/..", 0o777) # inside the destination while x does not exist
      w.add_symlink("x", ".", 0o777)    # now T resolves to the destination's parent
    end

    extract_archive(hs_archive, hs_target)

    expect(File.symlink?(File.join(hs_target, "T"))).to be false
    expect(File.symlink?(File.join(hs_target, "x"))).to be true
  end

  it "keeps an existing symlinked directory inside the destination when the archive has a directory entry for it" do
    hs_symlinks_supported!
    real = File.join(hs_target, "real")
    FileUtils.mkdir_p(real)
    File.symlink(real, File.join(hs_target, "lnk"))
    hs_build do |w|
      w.mkdir("lnk", 0o755)
    end

    extract_archive(hs_archive, hs_target)

    expect(File.symlink?(File.join(hs_target, "lnk"))).to be true
    expect(File.directory?(real)).to be true
  end

  it "reports refused entries at error level so they are visible by default" do
    hs_build { |_w, f| f.write(hs_header("hl", "1", linkname: hs_secret)) }

    expect(Mixlib::Archive::Log).to receive(:error).with(/hl/).at_least(:once)

    extract_archive(hs_archive, hs_target)
  end

  it "still extracts regular files, directories and in-destination symlinks" do
    hs_symlinks_supported!
    hs_build do |w|
      w.mkdir("d", 0o755)
      w.add_file_simple("d/f.txt", 0o644, 5) { |io| io.write("hello") }
      w.add_symlink("d/ln", "f.txt", 0o777)
    end

    extract_archive(hs_archive, hs_target)

    expect(File.read(File.join(hs_target, "d", "f.txt"))).to eq("hello")
    expect(File.read(File.join(hs_target, "d", "ln"))).to eq("hello")
  end
end
