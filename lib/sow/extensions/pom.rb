require 'pom'

module Sow

  class Session

    #
    def project
      @project
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
          Metadata.new(environment, project.metadata)
        else
          Metadata.new(environment)
        end
      )
    end

  end

end
