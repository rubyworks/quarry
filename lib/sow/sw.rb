require 'sow/sower_eval'

module Sow

  #
  class Sowfile

    PATTERN = '{,_}Sowfile'

    #
    def initialize(path)
      @setup = nil
      @seeds = {}

      @path = path
      @file = Dir[path + PATTERN].first 

      #instance_eval(File.read(@file), @file)
    end

    # Location of Sowfile.
    attr :path

    # Full path to Sowfile.
    attr :file

    # Hash of defined seeds.
    attr :seeds

    #
    def setup(&block)
      @setup = block if block
      @setup
    end

    #
    def seed(name, &block)
      @seeds[name.to_sym] = Seed.new(self, name, setup, &block)
      @seeds[name.to_sym]
    end

    #
    def sow!(name, args, data, opts)
      seed(name).call(args, data, opts)
    end

    #
    def to_s
      @file
    end

  end


  #
  class Seed

    #
    def initialize(sowfile, name, setup, &block)
      @sowfile = sowfile
      @name    = name
      @setup   = setup
      @block   = block
    end

    #
    def call(arguments, settings, options)
      eval = Eval.new(self, arguments, settings, options)
      eval.call
    end

    #
    def sowfile
      @sowfile
    end

    #
    def name
      @name
    end

    #
    def setup
      @setup
    end

    #
    def block
      @block
    end

  end

end
