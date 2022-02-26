lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mixlib/archive/version"

Gem::Specification.new do |spec|
  spec.name          = "mixlib-archive"
  spec.version       = Mixlib::Archive::VERSION
  spec.authors       = ["Chef Software, Inc"]
  spec.email         = ["info@chef.io"]

  spec.summary       = %q{A simple interface to various archive formats}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/chef/mixlib-archive"
  spec.license       = "Apache-2.0"
  spec.required_ruby_version = ">= 2.5"

  spec.files         = %w{LICENSE} + Dir.glob("lib/**/*")
  spec.require_paths = ["lib"]

  spec.add_dependency "mixlib-log"
end
