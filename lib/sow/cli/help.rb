require 'sow/cli/abstract'

module Sow::CLI

  class Help < Abstract

    #
    def call(argv)
      if name = argv.first
        puts manager.readme(name)
      else
        puts "sow <seed> [args...]     # germinate a seed"
        puts "sow bank                 # list all available seeds"
        puts "sow bank install <uri>   # install a new seed bank"
        puts "sow bank update [name]   # update seed bank(s)"
        puts "sow bank remove <name>   # remove a seed bank"
        puts "sow help                 # show this help message"
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

