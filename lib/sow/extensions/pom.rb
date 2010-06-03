require 'pom'

module Sow

  class Session

    #
    def project
      @project ||= POM::Project.new(destination)
    end

    #
    def project?
      project ? true : false
      #destination.exist? #&& (
      #  destination.glob('VERSION').first ||
      #  destination.glob('PROFILE').first
      #)
    end

    #
    def metadata
      @metadata ||= (
        if project?
          Metadata.new(project.metadata)
        else
          Metadata.new()
        end
      )
    end

  end

end
