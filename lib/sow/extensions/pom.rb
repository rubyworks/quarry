begin
  require 'pom'
rescue LoadError
end

module Sow

  class Session

    # Returns an instance of POM::Project, if available.
    def pom
      if defined?(POM) && destination.exist?
        @pom ||= POM::Project.new(destination)
      end
    end

    # Use this method to see if pom is available.
    def pom?
      pom ? true : false
    end

    # Override metadata to include POM metadata.
    def metadata
      @metadata ||= (
        if pom?
          Metadata.new(pom.metadata)
        else
          srcs = load_raw_pom_metadata.compact
          Metadata.new(*srcs)
        end
      )
    end

    # Fallback if POM library is not available but 
    # POM metadata is in project nontheless.
    def load_raw_pom_metadata
      profile = nil
      verfile = nil
      if destination.glob('PROFILE').first
        begin
          profile = YAML.load(File.new('PROFILE'))
        rescue
        end
      end
      if destination.glob('VERSION').first
        begin
          verfile = YAML.load(File.new('VERSION'))
          if Hash===verfile
            verfile.rekey!
            verfile[:version] = verfile.values_at(:major,:minor,:patch,:state,:build).compact.join('.')
          else
            verfile = {:version => version}
          end
        rescue
        end
      end
      return profile, verfile
    end

  end#class Session

end#module Sow
