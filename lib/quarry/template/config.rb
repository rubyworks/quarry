module Quarry
  class Template

    # Models the `template.yml` file.
    #
    class Config

      #
      def initialize(template)
        @template = template
        @file     = template.path + CONFIG_FILE  #Dir.glob(@path + CONFIG_FILE).first
        @config   = YAML.load_file(@file.to_s)
      end

      #
      attr :template

      #
      # The `template.yml` as a Pathname instance.
      #
      # @return [Pathname] The `template.yml` file.
      #
      attr :file

      #
      # Hash of README entries, default is English (`en`).
      #
      def readmes
        @readmes ||= (
          readmes = {}
          @config.each do |term, text|
            if md = /^readme/i.match(term)
              lang = File.extname(term)
              lang = 'en' if lang.empty?
              readmes[lang] = Readme.new(text)
            end
          end
          readmes
        )
      end

      #
      #
      #
      def readme(lang='en')
        readmes[lang]
      end

      #
      # Copy script.
      #
      def script
        @config['script']
      end

      #
      #
      #
      def [](key)
        @config[key]
      end

    end

  end

end
