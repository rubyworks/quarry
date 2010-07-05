require 'sow/cli/abstract'
require 'sow/copier'

module Sow::CLI

  # Utilize backup and "uproot" previous sowing.
  class Undo < Abstract

    #
    def call(argv)
      options.backup = false
      output = options.output || Dir.pwd
      backup = Dir[File.join(output, '.sow/undo/*')].sort.last
      copier = Sow::Copier.new(backup, output, options)
      copier.copy
      FileUtils.rm_r(backup)
    end

    #
    def opts
      OptionParser.new{ |o|
        o.on('--output', '-o PATH'){ |path| options.output = path }
        o.on('--write' , '-w'){ options.mode = :write }
        o.on('--prompt', '-p'){ options.mode = :prompt }
        o.on('--skip'  , '-s'){ options.mode = :skip }
        o.on('--dryrun'      ){ $DRYRUN = true }
        o.on('--debug'       ){ $DEBUG  = true }
        o.on('--help', '-h'  ){ puts o; exit }
      }
    end

  end

end
