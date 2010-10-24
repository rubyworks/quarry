# This extension adds some color manipulation via the color gem,
# which is useful for generating websites.

require 'color'

module Sow

  class Sowfile

    #class Context

      # Returns an instance of Color given an HTML color string.
      # Simply use #html on the color to get an HTML valid color string.
      def color(color)
        Color::RGB.from_html(color)
      end

      # Take a +keyword+ and calculate a unique color from it.
      # Simply use #html on the color to get an HTML valid color string.
      def color_from_keyword(word)
        key = (word+"ZZZ").sub(/[aeiou]/,'')[0,3].upcase.sub(/\W/,'')
        rgb = key.each_byte.to_a.map{ |i| (i-65)*10 }
        Color::RGB.new(*rgb)
      end

      # Return a random instance of Color.
      # Simply use #html on the color to get an HTML valid color string.
      def color_random
        Color::RGB.new(rand(255),rand(255),rand(255))
      end

    #end

  end

end

