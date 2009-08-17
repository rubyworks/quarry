=begin
  # NOTE: These are now in Facets.
  module Pathname

    #
    def split_root
      head, tail = *::File.split_root(to_s)
      [self.class.new(head), self.class.new(tail)]
    end

    #
    def glob(match, options=0)
      Dir.glob(::File.join(self.to_s, match), options).collect{ |m| self.class.new(m) }
    end

    #
    def globfirst(match, options=0)
      file = ::Dir.glob(::File.join(self.to_s, match), options).first
      file ? self.class.new(file) : nil
    end

    #
    def empty?
      Dir.glob(::File.join(self.to_s, '*')).empty?
    end

  end
=end

#class Pathname #:nodoc:
#  include Sow::Extensions::Pathname
#end

