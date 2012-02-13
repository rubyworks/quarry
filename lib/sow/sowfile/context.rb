module Sow

  class Sowfile

    # Templates are all rendered within the scope of a context object.
    # This limits access to information pertinent. All metadata
    # can be accessed by name, as this this object delegate missing methods
    # to a Metadata instance.
    #
    class Context
      instance_methods.each{ |m| undef_method(m) unless m.to_s =~ /^(__|object_id$|respond_to\?$)/ }

      #
      def initialize(sower)
        @sower     = sower
        @sowfile   = sower.sowfile
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
          result
        elsif @sowfile.interactive?
          @metadata[s] = ask("#{s}: ")
        else
          @metadata[s] = "__#{s}__"
          #super(s,*a,&b)
        end
      end

      #
      #def method_missing(s, *a, &b)
      #  @metadata[s.to_s] || "__#{s}__"  # "__'#{s}'__"
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
        "#<Sow::Sowfile::Context>"
      end
    end


  end

end
