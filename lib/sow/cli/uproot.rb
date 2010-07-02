require 'sow/cli/abstract'

module Sow::CLI

  class Undo < Abstract

    def call(argv)
      app.undo
    end

    def opts
      OptionParser.new{ |o|
        #o.on('--write' , '-w'){ options.mode = :write }
        o.on('--prompt', '-p'){ options.mode = :prompt }
        o.on('--skip'  , '-s'){ options.mode = :skip }
        o.on('--dryrun'      ){ $DRYRUN = true }
        o.on('--debug'       ){ $DEBUG  = true }
        o.on('--help', '-h'  ){ puts o; exit }
      }
    end

  end

end
