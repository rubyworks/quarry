#!/usr/bin/env ruby

require 'ratchets/scaffold/controller'

module ProUtils

  class ScaffoldCommand #< Console::Command

    def self.start
      new.start
    end

    def initialize
      args, opts = Console::Arguments.new.parse

      help if opts['help']

      @type = args[0].to_s.downcase

      exit -1 if @type == ''

      @dryrun = opts['dryrun'] || opts['noharm'] || opts['n']
    end

    def __help
      $stdout << File.read(File.join(File.dirname(__FILE__), 'help.txt'))
      exit 0
    end

    def __dryrun
      @dryrun = true
    end
    alias :__noharm, :__dryrun
    alias :_n, :__dryrun

    def start
      Architect.scaffold(@type, :dryrun => @dryrun)
    end

    def help
      $stdout << File.read(File.join(File.dirname(__FILE__), 'help.txt'))
      exit 0
    end

  end #class Command

end

