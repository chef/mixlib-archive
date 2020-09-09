$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "tmpdir" unless defined?(Dir.mktmpdir)
require "mixlib/archive/tar"
require "mixlib/archive/lib_archive"
require "pathname" unless defined?(Pathname)

module Fixtures
  def fixtures_path
    spec_root.join("fixtures")
  end

  def spec_root
    Pathname.new(File.expand_path(__dir__))
  end
end

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.include Fixtures
end
