source "https://rubygems.org"

gemspec

gem "ffi-libarchive"

group :docs do
  gem "yard"
  gem "redcarpet"
  gem "github-markup"
end

group :test do
  gem "chefstyle", git: "https://github.com/chef/chefstyle.git", branch: "master"
  gem "rspec", "~> 3.0"
  gem "rake"
end

group :debug do
  gem "pry"
  gem "pry-byebug"
  gem "pry-stack_explorer"
  gem "rb-readline"
end

instance_eval(ENV["GEMFILE_MOD"]) if ENV["GEMFILE_MOD"]

# If you want to load debugging tools into the bundle exec sandbox,
# add these additional dependencies into Gemfile.local
eval_gemfile(__FILE__ + ".local") if File.exist?(__FILE__ + ".local")

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
