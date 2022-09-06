gemspec = eval(IO.read(File.expand_path("mixlib-archive.gemspec", __dir__))) # rubocop: disable Security/Eval

gemspec.platform = Gem::Platform.new(%w{X64_MINGW})

gemspec.files += Dir.glob("{distro}/**/*")

gemspec.required_ruby_version = ">= 3.1"

gemspec
