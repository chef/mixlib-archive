source "https://rubygems.org"

gemspec name: "mixlib-archive"

# need the extract=to-destination support in ffi-libarchive 1.0.17
gem "ffi-libarchive", ">= 1.0.17"

group :test do
  gem "cookstyle", ">= 7.32.8"
  gem "rake"
  gem "rspec", "~> 3.0"
end

group :debug do
  gem "pry"
  gem "pry-byebug"
  gem "rb-readline"
end

# These lines added for Windows (x64) development only.
# For ffi-libarchive to function during development on Windows we need the
# binaries in the RbConfig::CONFIG["bindir"]
#
# We copy (and overwrite) these files every time "bundle <exec|install>" is
# executed, just in case they have changed.
if RUBY_PLATFORM =~ /mswin|mingw|windows/
  instance_eval do
    ruby_exe_dir = RbConfig::CONFIG["bindir"]
    assemblies = Dir.glob(File.expand_path("distro/ruby_bin_folder", Dir.pwd) + "/*.dll")
    FileUtils.cp_r assemblies, ruby_exe_dir, verbose: false unless ENV["_BUNDLER_LIBARCHIVE_DLLS_COPIED"]
    ENV["_BUNDLER_LIBARCHIVE_DLLS_COPIED"] = "1"
  end
end
