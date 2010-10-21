begin
  require 'gemdo'

  module Sow

    class SowerEval

      # Access to POM project object. Thus is useful for scaffoling
      # Ruby project's that conform to POM specs. Keep in mind that
      # this POM object points to the temporary duplicate of the project
      # and not the actual project.
      #
      # Returns an instance of POM::Project, if available.
      def pom_project
         @pom_project ||= Gemdo::Project.lookup(work_path.to_s) #working_directory)
      end

      #
      def pom_settings
         @pom_settings ||= (pom_project ? pom_project.metadata : {})
      end

      class Metadata
        # Add project metadata to metadata lookup.
        #
        # TODO: This is "extreme" and we need a better way to handle it.
        #
        def settings
          @settings ||= [
            #ENV,
            #@sower.seed_setting,
            @sower.user_settings,
            @sower.pom_project.profile.to_h,
            @sower.pom_project.package.to_h,
            #@sower.pom_settings,
            @sower.work_settings,
            @sower.settings
          ]
        end
      end

      class Context
        # Access to POM project object. Thus is useful for scaffoling
        # Ruby project's that conform to POM specs. Keep in mind that
        # this POM object points to the temporary duplicate of the project
        # and not the actual project.
        #
        # Returns an instance of POM::Project, if available.
        def project
          @sower.pom_project
        end
      end
    end

  end

rescue LoadError

  # Hey, where's the POM?
  warn 'Gemdo is not installed.'

end

