# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mixlib/archive/version"

Gem::Specification.new do |spec|
  spec.name          = "mixlib-archive"
  spec.version       = Mixlib::Archive::VERSION
  spec.authors       = ["Chef Software, Inc"]
  spec.email         = ["info@chef.io"]

  spec.summary       = %q{A simple interface to various archive formats}
  spec.description   = spec.summary
  spec.homepage      = "https://chef.io"
  spec.license       = "APACHE-2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 11.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "chefstyle"
  spec.add_dependency "mixlib-log"
end
