module Quarry

  #
  class Config

    #
    def initialize(stage)
      @stage   = stage
    end

    #
    def key?(name)
      name = name.to_s
      return true if metadata_proj.key?(name)
      return true if metadata_home.key?(name)
      false
    end

    #
    def [](name)
      name = name.to_s
      return metadata_proj[name] if metadata_proj.key?(name) # in which order -'
      return metadata_home[name] if metadata_home.key?(name)
      nil
    end

    # Metadata gathered from the project's .quarry configuration.
    def metadata_proj
      @metadata_proj ||= (
        if file = file_metadata_proj
          YAML.load(File.new(file))
        else
          {}
        end
      )
    end

    # Metadata gathered from the user's quarry configuration.
    def metadata_home
      @metadata_home ||= (
        if file = file_metadata_home
          YAML.load(File.new(file))
        else
          {}
        end
      )
    end

    # TODO: support .config/quarry too ?
    def file_metadata_proj
      @file_metadata_proj ||= Dir[File.join(@stage, '.quarry/metadata{,.yml,.yaml}')].first
    end

    #
    def file_metadata_home
      @file_metadata_home ||= Dir[File.expand_path('~/.config/quarry/metadata{,.yml,.yaml}')].first
    end

  end

end
