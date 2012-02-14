module Quarry
  class Template

    # Handles README section of template.yml.
    #
    class Readme

      def initialize(data)
        case data
        when nil
          @text = "No documentation."
        when Hash
          @text = construct_text(data)
        else
          @text = data.to_s
        end
      end

      def to_s
        @text
      end

    private
 
      # TODO: Continue to improve.
  
      #
      def contstruct_text(data)
        s << "# " + data['title']
        s << "## DESCRIPTION"
        s << data['description']
        s << "## SEE ALSO"
        s << (['quarry(1)'] + data['see also']).join(',')
        s
      end

    end

  end
end
