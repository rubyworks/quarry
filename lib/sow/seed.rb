require 'sow/core_ext'
require 'sow/config'
require 'sow/manager'
require 'sow/sower'

module Sow

  #
  class Seed

    # Basenames of files to ignore in template files.
    IGNORE = %w{. .. .svn}

    # Files to remove in template files.
    REMOVE = %w{Sowfile _Sowfile _README}

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
    # ## ARGUMENTS
    #
    #   * `name`
    #     Name of the seed (or best prefix match).
    #
    #   * `arguments`:
    #     Seeds can accept an Array of *arguments* which can refine their 
    #     behvior.
    #
    #   * `settings`:
    #     Seed can accept a Hash of `key=>value` *settings* which refine
    #     their behavior.
    #
    #--
    # TODO: OPTIONS?
    #++
    def initialize(name, arguments, settings)
      @name      = name
      @arguments = arguments
      @settings  = settings

      @directory = self.class.find(name)

      raise "No seed -- #{name}" unless @directory

      @sowfile = Dir[@directory + '{,_}Sowfile'].first 
    end

    # Name of seed.
    def name
      @name
    end

    # Arguments (from commandline).
    def arguments
      @arguments
    end

    # Metadata settings (from commandline).
    def settings
      @settings 
    end

    #
    #def options; @options ; end

    # Seed directory.
    def directory
      @directory
    end

    #
    def sowfile
      @sowfile
    end

    #
    def script
      @script ||= (
        s = File.read(sowfile).strip
        s.empty? ? "copy all" : s
      )
    end

    # Returns the list of seed files.
    def files
      @files ||= (
        files = []
        Dir.recurse(directory.to_s) do |path|
          next if IGNORE.include?(File.basename(path))
          files << path.sub(directory.to_s+'/','')
        end
        files - REMOVE
      )
    end

    #
    #def destination_directory
#puts "==> #{(options.output || Dir.pwd)}"
    #  @destination ||= (options.output || Dir.pwd)
    #end

    # Present working directory.
    #def working_directory
    #  @work
    #end

    # Do it!
    #def sow!(stage, options)
    #  sower = Sower.new(self, options)
    #  sower.sow!(stage)
    #end

  end

end

