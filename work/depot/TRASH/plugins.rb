require 'sow/script'

module Sow

  ### = Plugins
  ### 
  ### The Plugins class manges the loading of sow generator/scaffold plugins.
  ###
  class Plugins

    LOCAL = Pathname.new(File.dirname(__FILE__))

    attr :plugins
    attr :admin

    def initialize(admin)
      @admin = admin
      @plugins = []
      # order is important here
      load_plugins(custom_directory)
      load_plugins(standard_directory)
    end

    def generators
      @generators ||= plugins.inject({}){|l,p| l.update(pl.generators); l}
    end

    def scaffolds
      @scaffolds ||= plugins.inject({}){|l,p| l.update(pl.scaffolds); l}
    end

    def loggers
      @loggers ||= plugins.inject({}){|l,p| l.update(pl.loggers); l}
    end 

  private

    ###
    def standard_directory
      @standard_directory ||= LOCAL + 'plugins'
    end

    ###
    def custom_directory
      admin + 'plugins'
    end

    ###
    def load_plugins(path)
      return unless path.exist?
      path.glob('*/config.yaml').each do |f|
        config = YAML.load(File.new(f))
        if config['master'].downcase == 'sow'
          plugins << Plugin.new(f.dirname, config)
        end
      end
    end

  end

  ### = Plugin
  ###
  class Plugin
 
    FILENAME = 'generator.rb'

    attr :location
    attr :config

    def initialize(location, config)
      @location = location
      @config   = config
    end

    def version ; config['version'] ; end

    def script
      @script ||= Script.load(location)
    end

    def generators
      @script.generators
    end

    def scaffolds
      @script.scaffolds
    end

    def loggers
      @script.loggers
    end

  end

end

