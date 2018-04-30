$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "tmpdir"
require "mixlib/archive"
require "mixlib/archive/tar"
require "mixlib/archive/lib_archive"

module Fixtures
  def fixtures_path
    spec_root.join("fixtures")
  end

  def spec_root
    Pathname.new(File.expand_path(File.dirname(__FILE__)))
  end
end

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.include Fixtures
end
