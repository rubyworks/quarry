require 'sow/cli/abstract'

module Sow::CLI

  class Help < Abstract

    command 'help'

    #
    def call(argv)
      if name = argv.first
        puts manager.readme(name)
      else
        puts "sow new <path> <seed> ...      # germinate a new seed"
        puts "sow gen <seed> ...             # germinate a seed"
        puts "sow seed                       # list all available seeds"
        puts "sow seed save <name>           # save personal seed"
        puts "sow seed remove <name>         # remove personal seed"
        puts "sow bank list                  # list installed seed banks"
        puts "sow bank install <uri> [name]  # install a seed bank"
        puts "sow bank uninstall <name>      # uninstall a seed bank"
        puts "sow bank update [name]         # update seed bank(s)"
        puts "sow copy <src> <dest>          # germinate from directory"
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

