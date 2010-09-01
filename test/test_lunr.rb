require "minitest/autorun"
require "fakeweb"
require "lunr"

FakeWeb.allow_net_connect = false

class TestLunr < MiniTest::Unit::TestCase
  def setup
    FakeWeb.clean_registry
  end
end
