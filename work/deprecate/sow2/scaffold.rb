require 'reap/system'
require 'sow/directory'

module Sow

  #
  class Scaffold < Reap::System

    #
    attr_accessor :about

    #
    attr_accessor :usage

    #
    attr_reader :arguments

    #
    attr_reader :copylist

    #
    attr_reader :renderings

    #
    attr_reader :modifications

    #
    attr_reader :deletions

    # Access to source's files.
    attr_reader :source

    # Access to destination's files.
    attr_reader :destination

    # Create a Scaffold object.
    #
    # source - path to source directory
    # destination - path to destination directory
    #
    def initialize(source, destination)
      @about         = nil
      @usage         = nil
      @arguments     = []
      @copylist      = []
      @renderings    = []
      @modifications = []
      @deletions     = []

      @source        = Directory.new(source)
      @destination   = Directory.new(destination)

      file = File.join(source, 'Sowfile')

      super(file)
    end

    #
    def <<(file)
      @files << Sowfile.new(self, file)
    end

    #
    def parse
      run
    end

  end

end

