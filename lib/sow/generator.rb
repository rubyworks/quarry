require 'fileutils'
require 'tmpdir'
require 'sow/seed'
require 'sow/copier'

module Sow

  # Sow's main application class. A generator is used
  # to "plant" seeds.
  class Generator

    #
    def initialize(seeds, options)
      @seeds   = seeds
      @options = options.to_ostruct

      @output  = @options.output || Dir.pwd

      destname = File.basename(@output).chomp('/')

      @stage = Dir.tmpdir + "/sow/stage/#{Time.now.to_i}/#{destname}"
    end


    # Seeds to germinate.
    def seeds
      @seeds
    end

    #
    def options
      @options
    end

    # Output directory.
    def output
      @output
    end

    alias_method :destination, :output

    # Temporary staging directory.
    def stage
      @stage
    end

    #
    #def config
    #  @config
    #end

    # Plant the seed! 
    #--
    # TODO: Rename to germinate ?
    #++
    def generate
      setup_stage(destination, stage)
      seeds.each do |seed|
        seed.sow!(stage)
      end
      managed_copy(stage, destination)
      #remove_stage(stage) unless $DEBUG
    end

    #
    def setup_stage(destination, stage)
      fu.mkdir_p(stage)
      #fu.mkdir_p(destination) unless File.exist?(destination)
      #fu.cp_r(destination+'/.', stage)
    end

    #
    def managed_copy(stage, destination)
      mg = Copier.new(stage, destination, copier_options)
      mg.copy
    end

    #
    def copier_options
      { :quiet  => options.quiet,
        :mode   => options.mode
      }
    end

    #
    def remove_stage(stage)
      fu.rm_r(stage)
    end

    #
    def fu
      FileUtils
    end

  end

end
