gemspec = eval(IO.read(File.expand_path("mixlib-archive.gemspec", __dir__))) # rubocop: disable Security/Eval

gemspec.platform = Gem::Platform.new(%w{universal mingw-ucrt})

gemspec.files += Dir.glob("{distro}/**/*")

gemspec
