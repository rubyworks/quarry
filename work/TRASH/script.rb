module Sow

  ### = Plugin Script
  ###
  ### This class is used to process the
  ### generator.rb scripts. It is stored
  ### by the plugin class.

  class Script

    FILENAME = 'generator.rb'

    def self.load(location)
      script = File.read(location + FILENAME)
      o = new
      o.instance_eval(script)
      o
    end

    attr :plugin
    attr :generators
    attr :scaffolds
    attr :loggers

    def initialize(plugin)
      @plugin = plugin
      @generators = []
      @scaffolds  = []
      @loggers    = []
    end

    def generator(name, &block)
      generators[name] = [plugin, block]
    end

    def scaffold(name, &block)
      scaffolds[name] = [plugin, block]
    end

    def logger(name, &block)
      loggers[name] = [plugin, block]
    end

  end

end
