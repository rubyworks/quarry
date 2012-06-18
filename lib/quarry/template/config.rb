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

      #
      # Get `arguments` from config file.
      #
      def arguments
        self['arguments']
      end

      # Take arguments from config and transform
      # them into `name, options` form.
      #
      def script_arguments
        @script_arguments ||= name_and_options(arguments)
      end

    private

      #
      def name_and_options(arguments)
        case arguments
        when Hash
          args.map do |name, default|
            [name, {:default=>default}]
          end
        else # Array
          args.map do |entry|
            case entry
            when Hash
              entry = entry.rekey
              name  = entry.delete(:name)
              [name, entry]
            when Array
              [entry.first, :default=>entry.last]
            else
              [entry, {}]
            end
          end
        end
      end

    end #class Config

  end #class Template
end #module Quarry
