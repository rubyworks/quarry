module Sow

  class CopyScript

    # Metdata access for filing in template slots.
    class Metadata
      alias_method :__class__, :class

      instance_methods.each{ |m| undef_method(m) unless m.to_s =~ /^(__|object_id$)/ }

      #
      def initialize(sowfile)
        @sowfile = sowfile
        @resources = sowfile.resources
        @data  = {}
        #@sources = [user_settings, work_settings, seed_settings]
        #@data  = sowfile.settings
      end

      #
      #def data
      #  @data
      #end

      # Get metadata entry.
      def [](name)
        name = name.to_s
        @resources.each do |resource|
          result = resource[name]
          return result if result
        end
        @data[name]
      end

      # Set metadata entry.
      def []=(name, value)
        @data[name.to_s] = value
      end

      #
      def method_missing(sym, *args)
        sym = sym.to_s
        case sym
        when /\=$/
          name = sym.chomp('=')
          self[name] = args.first
        when /\?$/
          self[sym.chomp('?')]
        when /\!$/
          # TODO: if method_missing ends in '!'
        else
          self[sym]
        end
      end

      #
      def to_h
        @resources.reverse.inject({}){ |h,r| h.merge!(r.to_h) }.merge!(@data)
      end

    end

  end

end
