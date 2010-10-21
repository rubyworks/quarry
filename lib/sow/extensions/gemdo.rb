begin
  require 'gemdo'

  module Sow

    class SowerEval

      # Access to POM project object. Thus is useful for scaffoling
      # Ruby project's that conform to POM specs. Keep in mind that
      # this POM object points to the temporary duplicate of the project
      # and not the actual project.
      #
      # Returns an instance of Gemdo::Project, if available.
      def project
         @project ||= Gemdo::Project.lookup(work.to_s) #working_directory)
      end

      #
      def project_settings
        #@pom_settings ||= (pom_project ? pom_project.metadata.to_h : {})
        @pom_settings ||= (
          sets = [project.profile.to_h, project.package.to_h]
          sets.inject({}){ |h,s| h.merge!(s); h }
        )
      end

      #
      def settings
        @settings ||= (
          sets = [user_settings, project_settings, work_settings, seed_settings]
          sets.inject({}){ |h,s| h.merge!(s); h }
        )
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
