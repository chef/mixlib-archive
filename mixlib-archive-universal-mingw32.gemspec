gemspec = eval(IO.read(File.expand_path("../mixlib-archive.gemspec", __FILE__)))

gemspec.platform = Gem::Platform.new(%w{universal mingw32})

gemspec.files += Dir.glob("{distro}/**/*")

gemspec
