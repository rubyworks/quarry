require 'quarry/cli/abstract'

module Quarry::CLI

  # Managed copy.
  class Copy < Abstract

    command 'copy'

    #
    def call(argv)
      from   = argv.shift
      to     = argv.shift
      Quarry.copy(from, to, options)
    end

    #
    def opts
      OptionParser.new{ |o|
        o.banner = "Usage: quarry copy <src> <dest>"
        #o.on('--output', '-o PATH'){ |path| options.output = path }
        o.on('--write' , '-w'){ options.mode = :write }
        o.on('--prompt', '-p'){ options.mode = :prompt }
        o.on('--skip'  , '-s'){ options.mode = :skip }
        o.on('--force' , '-f'){ $FORCE  = true }
        o.on('--dryrun'      ){ $DRYRUN = true }
        o.on('--debug'       ){ $DEBUG  = true }
        o.on('--help', '-h'  ){ puts o; exit }
      }
    end

  end

end
