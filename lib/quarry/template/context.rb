module Quarry
  class Template

    # Templates are all rendered within the scope of a context object.
    # This limits access to only pertinent information. All metadata
    # can be accessed by name, as this object delegates missing methods
    # to a Metadata instance.
    #
    class Context

      # Remove all non-essential methods.
      instance_methods.each{ |m| undef_method(m) unless m.to_s =~ /^(__|object_id$|respond_to\?$)/ }

      #
      def initialize(script)
        @script   = script
        @metadata = script.metadata
      end

      #
      # TODO: Should template scope have render method ?
      #
      #def render(file, options={})
      #  options[:file] = file
      #  options[:data] = self #binding
      #  Malt.render(options)
      #end

      #
      #def working_directory
      #  @metadata.mine.working_directory
      #end

      #
      # 
      #
      def method_missing(s,*a,&b)
        if result = @metadata[s]
          result
        elsif @script.interactive?
          @metadata[s] = ask("#{s}: ")
        else
          @metadata[s] = "___#{s}___"
          #super(s,*a,&b)
        end
      end

      #
      #
      #
      def to_h
        @metadata.to_h
      end

      #
      # Clean binding.
      #
      # @return [Binding] clean binding
      def to_binding
        binding
      end

      #
      # Concise inspect string.
      #
      def inspect
        "#<Quarry::Template::Context>"
      end
    end

  end
end
