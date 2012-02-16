module Quarry
  class Template
    class Script

      # Metdata access for filing in template slots.
      #
      class Metadata
        alias_method :object_class, :class

        instance_methods.each{ |m| undef_method(m) unless m.to_s =~ /^(__|object_id$|object_class$)/ }

        #
        #
        #
        def initialize(script)
          @script   = script
          @settings = script.settings
          @data  = {}
        end

        #
        # Get metadata entry.
        #
        def [](name)
          name = name.to_s
          return @data[name] if @data.key?(name)
          @settings.each do |s|
            result = s[name]
            return(@data[name] = result) if result
          end
          nil
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
        # Merge all settings resources into a single hash.
        #
        # @return [Hash]
        #
        def to_h
          @settings.reverse.inject({}){ |h,r| h.merge!(r.to_h) }.merge!(@data)
        end

        #
        # Clean binding, useful for rending in this context with ERB.
        #
        # @return [Binding]
        #
        def to_binding
          binding
        end

      end

    end
  end
end
