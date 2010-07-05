require 'sow/core_ext'
require 'sow/config'
require 'sow/manager'
require 'sow/sower'

module Sow

  #
  class Seed

    # Find a seed by +name+.
    def self.find(name)
      manager.find_seed(name)
    end

    # Reterun an instance of a seed manager.
    def self.manager
      @manager ||= Manager.new
    end

    # New Seed.
    #
    # name      - name of the seed (or best prefix match)
    # arguments - additional arguments for the seed
    # settings  - overriding metadata for the seed
    # options   - additional processing options
    #
    def initialize(name, arguments, settings, options)
      @name        = name
      @arguments   = arguments
      @settings    = settings || {}
      @options     = options.to_ostruct

      @source  = self.class.find(name)

      raise "No seed -- #{name}" unless @source

      @sowfile = (@source + '.sow/Sowfile').to_s
      @sowcode = File.read(@sowfile).strip
      @sowcode = "copy all" if @sowcode.empty?
    end

    # Name of seed.
    def name ; @name ; end

    # Arguments (from commandline).
    def arguments ; @arguments ; end

    # Metadata settings (from commandline).
    def settings; @settings ; end

    #
    def options; @options ; end

    # Seed's source directory.
    def source_directory
      @source
    end
    alias_method :source, :source_directory

    # Seed's template directory. The directory must be
    # name `template` or `templates`.
    def template_directory
      #@template_directory ||= source.glob('template{,s}').first
      @source
    end

    #
    def destination_directory
      @destination ||= (options.output || Dir.pwd)
    end

    # Do it!
    def sow!(stage)
      sower = Sower.new(self)
      Dir.chdir(stage) do
        #sower.instance_eval(@sowcode, @sowfile.to_s)
        eval(@sowcode, sower.to_binding, @sowfile.to_s)
      end
    end

  end

end

