require 'quarry/cli/abstract'

module Quarry::CLI

  class Help < Abstract

    command 'help'

    #
    def call(argv)
      if name = argv.first
        puts Quarry.help(name)
      else
        puts "quarry <name> ...                 # quarry a mine"
        puts "quarry mine <name> ...            # quarry a mine (same as `quarry <name>`)"
        puts "quarry new <dir> <name> ...       # quarry a mine to a new location"
        puts "quarry list                       # list available mines"
        puts "quarry save <name> [file ...]     # save files to a mine"
        puts "quarry remove <name>              # remove mine from mine bank"
        puts "quarry update [name]              # update mine(s) that were cloned"
        puts "quarry bank <uri> [name]          # clone mine into bank"
        puts "quarry copy <src> <dest>          # perform a quarry managed copy"
        puts "quarry help                       # show this help message"
      end
    end

    #
    def opts
      OptionParser.new{ |o|
        o.banner = "Usage: quarry help"
        o.on('--dryrun'      ){ $DRYRUN = true }
        o.on('--debug'       ){ $DEBUG  = true }
      }
    end

  end

end

