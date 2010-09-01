require "minitest/autorun"
require "mocha"
require "lunr/search"

class TestLunrSearch < MiniTest::Unit::TestCase
  include Lunr::Model

  def setup
    @search = Lunr::Search.new self.class
  end

  def test_initialize
    s = Lunr::Search.new self.class do
      with :foo, "bar"
    end

    assert_equal TestLunrSearch, s.klass
    assert_equal "type:TestLunrSearch", s.params[:fq].first
    assert s.params[:fq].include?("foo_s:bar")
  end

  def test_scope
    @search.scope { with :foo, "blergh" }
    @search.scope { with :bar, "corge"  }

    assert @search.params[:fq].include?("foo_s:blergh")
    assert @search.params[:fq].include?("bar_s:corge")
  end

  def test_scope_bad
    @search.stubs(:executed?).returns true

    assert_raises Lunr::AlreadyExecuted do
      @search.scope { with :foo, "hello" }
    end
  end
end

Sunspot.setup TestLunrSearch do
  string :bar
  string :foo
end
