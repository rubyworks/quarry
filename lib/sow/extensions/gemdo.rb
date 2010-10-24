begin
  require 'gemdo'
  require 'gemdo/readme'

  module Sow

    class Sowfile

      # Access to POM project object. Thus is useful for scaffoling
      # Ruby project's that conform to POM specs. Keep in mind that
      # this POM object points to the temporary duplicate of the project
      # and not the actual project.
      #
      # Returns an instance of Gemdo::Project, if available.
      def project
         @project ||= Gemdo::Project.lookup(work.to_s) #working_directory)
      end

      # List of resources that metadata can be drawn from. Each entry must
      # respond to #[].
      def resources
        [seed_settings, work_settings, project.package, project.profile, user_settings]
      end

      class Context
        # Access to POM project object. Thus is useful for scaffoling
        # Ruby project's that conform to POM specs. Keep in mind that
        # this POM object points to the temporary duplicate of the project
        # and not the actual project.
        #
        # Returns an instance of POM::Project, if available.
        def project
          @sower.project
        end
      end

    end

  end

rescue LoadError

  # Hey, where's the POM?
  # TODO: raise error? better would be an #availabilty validator for extensions.
  warn 'Gemdo is not installed.'

end
