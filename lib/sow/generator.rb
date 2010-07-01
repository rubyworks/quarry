require 'fileutils'
require 'tmpdir'
require 'sow/seed'
require 'sow/copier'

module Sow

  # Sow's main application class. A generator is used
  # to "plant" seeds.
  class Generator

    #
    def initialize(options)
      @options     = options

      @seed        = options.seed
      @arguments   = options.arguments
      @settings    = options.settings
      @destination = options.output || Dir.pwd
      @stage       = Dir.tmpdir + "/sow/stage/#{Time.now.to_i}"
      #@config      = Config.new(@stage)
    end

    #
    def options
      @options
    end

    #
    def seed
      @seed
    end

    #
    def arguments
      @arguments
    end

    #
    def settings
      @settings
    end

    #
    def destination
      @destination
    end

    # TODO: Add name to stage.
    def stage
      @stage
    end

    #
    def config
      @config
    end

    # Plant the seed! TODO: Rename to germinate?
    def generate
      archive_copy(destination, stage)
      Seed.new(seed, arguments, settings).sow!(stage)
      managed_copy(stage, destination)
      #remove_stage(stage) unless $DEBUG
    end

    #
    def archive_copy(destination, stage)
      fu.mkdir_p(stage)
      fu.mkdir_p(destination) unless File.exist?(destination)
      fu.cp_r(destination+'/.', stage)
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
