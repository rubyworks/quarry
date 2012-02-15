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
      #
      #
      def [](key)
        @config[key.to_s]
      end

    end

  end

end
