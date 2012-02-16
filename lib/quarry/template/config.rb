module Quarry
  class Template

    # Models the `template.yml` file.
    #
    class Config

      # Lookup glob for `config.yml` file.
      GLOB = TEMPLATE_DIRECTORY + '/config.{yml,yaml}'

      #
      def initialize(template)
        @template = template
        @file     = Dir.glob(template.path + GLOB).first

        if @file
          @config = YAML.load_file(@file.to_s) || {}
        else
          @config = {}
        end
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
      #
      #
      def [](key)
        @config[key.to_s]
      end

      #
      # Project files to use as metadata resources, if they exist.
      # Supported formats are YAML and JSON. YAML is assumed if the
      # file lacks an extension.
      #
      # @example
      #   resource:
      #     - .ruby
      #
      def resource
        self[:resource] || self[:resources]
      end

    end

  end

end

