require 'sow/cli/abstract'

module Sow::CLI

  class Help < Abstract

    #
    def call(argv)
      if name = argv.first
        puts manager.readme(name)
      else
        puts "sow gen <seed> [args...]       # germinate a seed"
        puts "sow new <fname> <seed> [args...] # germinate a new seed"
        puts "sow bank                         # list all available seeds"
        puts "sow bank install <uri>           # install a seed bank"
        puts "sow bank uninstall <name>        # uninstall a seed bank"
        puts "sow bank update [name]           # update seed bank(s)"
        puts "sow bank save <name>             # save personal seed"
        puts "sow bank delete <name>           # delete personal seed"
        puts "sow help                         # show this help message"
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

