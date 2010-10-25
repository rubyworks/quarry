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
        puts "sow new <path> <name> ...      # sow a seed to a new location"
        puts "sow list                       # list available seeds"
        puts "sow seed <name> ...            # sow a seed  (same as `sow <name>`)"
        puts "sow seed list                  # list available seeds (same as `sow list`)"
        puts "sow seed save <name>           # save personal seed"
        puts "sow seed remove <name>         # remove personal seed"
        puts "sow bank list                  # list installed seed banks"
        puts "sow bank install <uri> [name]  # install a seed bank"
        puts "sow bank uninstall <name>      # uninstall a seed bank"
        puts "sow bank update [name]         # update seed bank(s)"
        puts "sow copy <src> <dest>          # perform a sow managed copy"
        puts "sow help                       # show this help message"
      end
    end

    #
    def opts
      OptionParser.new{ |o|
        o.on('--dryrun'      ){ $DRYRUN = true }
        o.on('--debug'       ){ $DEBUG  = true }
      }
    end

  end

end

