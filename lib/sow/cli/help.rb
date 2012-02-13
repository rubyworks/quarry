require 'sow/cli/abstract'

module Sow::CLI

  class Help < Abstract

    command 'help'

    #
    def call(argv)
      if name = argv.first
        Sow.help(name)
      else
        puts "sow <name> ...                 # sow a seed"
        puts "sow seed <name> ...            # sow a seed (same as `sow <name>`)"
        puts "sow new <dir> <name> ...       # sow a seed to a new location"
        puts "sow list                       # list available seeds"
        puts "sow save <name> [file ...]     # save files to a seed"
        puts "sow remove <name>              # remove seed from seed bank"
        puts "sow update [name]              # update seed(s) that were cloned"
        puts "sow bank <uri> [name]          # clone seed into bank"
        puts "sow copy <src> <dest>          # perform a sow managed copy"
        puts "sow help                       # show this help message"
      end
    end

    #
    def opts
      OptionParser.new{ |o|
        o.banner = "Usage: sow help"
        o.on('--dryrun'      ){ $DRYRUN = true }
        o.on('--debug'       ){ $DEBUG  = true }
      }
    end

  end

end

