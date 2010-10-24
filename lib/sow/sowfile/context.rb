module Sow

  class Sowfile

    # Templates are all rendered within the scope of a context object.
    # This limits access to information pertinent. All metadata
    # can be accessed by name, as this this object delegate missing methods
    # to a Metadata instance.
    class Context
      instance_methods.each{ |m| undef_method(m) unless m.to_s =~ /^(__|object_id$|respond_to\?$)/ }

      #
      def initialize(sower)
        @sower     = sower
        @metadata  = sower.metadata
        #@metadata = metadata.data.rekey(&:to_s)
      end

      #
      def render(file, options={})
        options[:file] = file
        options[:data] = self #binding
        Malt.render(options)
      end

      #
      #def working_directory
      #  @metadata.seed.working_directory
      #end

      #
      def method_missing(s,*a,&b)
        if result = @metadata[s]
          return result
        end
        #if @metadata.key?(s.to_s)
        #  @metadata[s.to_s]
        #else
          "___#{s}___"
          #super(s,*a,&b)
        #end
      end

      #
      #def method_missing(s, *a, &b)
      #  @metadata[s.to_s] || "___#{s}___"  # "__'#{s}'__"
      #end

      # FIXME: include resources
      def to_h
        metadata.to_h
      end

      #
      def to_binding
        binding
      end

      #
      def inspect
        "#<Sow::Sower::Context>"
      end
    end


  end

end
