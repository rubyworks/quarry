require 'quarry/cli/abstract'
require 'quarry/copier'

module Quarry::CLI

  # Utilize backup and undo previous quarrying.
  #
  class Undo < Abstract

    command 'undo'

    #
    def call(argv)
abort "not functional yet"
      options.backup = false
      output = options.output || Dir.pwd
      backup = Dir[File.join(output, '.quarry/undo/*')].sort.last
      copier = Quarry::Copier.new(backup, output, options)
      copier.copy
      FileUtils.rm_r(backup)
    end

    #
    def opts
      OptionParser.new{ |o|
        o.banner = "Usage: quarry undo"
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
