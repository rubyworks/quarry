module Quarry
  class Template

    # Handles README files of a template.
    #
    class Readme

      GLOB = TEMPLATE_DIRECTORY + "/README{,.*}"

      #
      #
      #
      def initialize(template)
        @template = template
        @files    = Dir.glob(template.path + GLOB)

        @lang = {}
        @files.each do |file|
          ext = File.extname(file)
          ext = '.en' if ext.empty?
          @lang[ext[1..-1]] = file
        end
      end

      #
      # @todo Appropriate way to handle language?
      #
      def to_s(lang='en')
        if @files.empty?
          construct_readme
        else
          File.read(@text[lang])
        end
      end

    private

      #
      # Generate a README from template configuration. This is used if no README
      # file is provided.
      #
      def contstruct_readme
        config = template.config

        s = []
        s << "# %s - %s" % [config[:name], config[:summary]]
        s << "## SYNOPSIS"
        s << Array(usage).join("\n")
        s << "## DESCRIPTION"
        s << config[:description]
        s << "## COPYRIGHT"
        s << config[:copyright]
        s.join("\n\n")
      end

    end

  end
end
