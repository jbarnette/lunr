require "minitest/autorun"
require "fakeweb"
require "lunr"

FakeWeb.allow_net_connect = false

class TestLunr < MiniTest::Unit::TestCase
  def setup
    FakeWeb.clean_registry
  end

  def test_self_search
    stub "foo"
    Lunr.search "foo"
  end

  def stub query, fixture = "simple"
    FakeWeb.register_uri :get, url(query),
      :body => File.read("test/fixtures/#{fixture}")
  end

  def url query
    "#{Lunr[:url]}/select?wt=ruby&start=0&q=#{query}&rows=25"
  end
end
