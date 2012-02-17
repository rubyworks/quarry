# Foo classes are powerful stuff.

class Foo

  # This is the infamous Foo#bar method.
  #
  def bar
    "FOOBAR!!!"
  end

end


=begin demo

  puts Foo.bar.new

=end


=begin test

  require 'test/unit'

  class TestThis < Test::Unit::TestCase

    def test_foo
      assert_equal("FOOBAR!!!", Foo.new.bar)
    end

  end

=end
