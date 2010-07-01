begin
  require 'pom'

  module Sow
    class Sower
      # Access to POM project object. Thus is useful for scaffoling
      # Ruby project's that conform to POM specs. Keep in mind that
      # this POM object points to the temporary duplicate of the project
      # and not the actual project.
      #
      # Returns an instance of POM::Project, if available.
      def pom
        @pom ||= POM::Project.new(Dir.pwd)
      end

      class Data
        def metadata_sources
          [@data, @seed.settings, @seed.config, @seed.pom.metadata, ENV]
        end
      end
    end
  end#module Sow

rescue LoadError
  # hey, where's the pom?
  warn 'POM is not installed.'
end

