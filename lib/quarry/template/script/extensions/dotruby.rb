module Quarry

  class Script

    #
    # Access to .ruby project metadata. This is useful for scaffoling
    # Ruby project's that use .ruby. 
    #
    # Keep in mind that this data comes from the temporary duplicate
    # of the project and not the actual project.
    #
    # @return [Hash] Metadata from .ruby file, if available.
    #
    def dotruby
      @dotruby ||= (
        file = File.join(output, '.ruby')
        File.exist?(file) ? YAML.load(file) : {}
      )
    end

    #
    # List of resources that metadata can be drawn from. Each entry must
    # respond to #[].
    #
    def resources
      [template_settings, work_settings, dotruby, user_settings]
    end

    class Context
      #
      # Access to .ruby project metadata. This is useful for scaffoling
      # Ruby project's that ise .ruby. 
      #
      def dotruby
        @copy_script.doturby
      end
    end

  end

end

