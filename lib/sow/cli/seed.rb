require 'sow/cli/abstract'
require 'sow/sower'
require 'sow/seed'

module Sow::CLI

  # Sow seed(s). This is the deafult commandline interface.
  class Seed < Abstract

    command ''
    command 'seed'

    #
    def call(argv)
      seeds = parse_seeds(argv)
      sower = Sow::Sower.new(seeds, options)
      sower.sow!
    end

    #
    def opts
      OptionParser.new{ |o|
        o.banner = "Usage: sow <seed>"
        o.separator "Sow a seed."
        o.on('--output', '-o PATH'){ |path| options.output = path }
        o.on('--write' , '-w'){ options.mode = :write }
        o.on('--prompt', '-p'){ options.mode = :prompt }
        o.on('--skip'  , '-s'){ options.mode = :skip }
        o.on('--force' , '-f'){ $FORCE  = true }
        o.on('--dryrun'      ){ $DRYRUN = true }
        o.on('--debug'       ){ $DEBUG  = true }
        o.on('--help', '-h'  ){ puts o; exit }
      }
    end

    #
    def parse_seeds(argv)
      groups = [[]]
      argv.each do |arg|
        if arg == '-'
          next if groups.last.empty?
          groups << []
        else
          groups.last << arg
        end
      end
      groups.map do |args|
        settings, arguments = parse_settings(args)
        name = arguments.shift
        [name, arguments, settings]
      end
    end

    # Parse out the metadata setting given on the commandline.
    def parse_settings(argv)
      env = {}
      sets, args = *argv.partition{ |x| /=/ =~ x }
      sets.each do |x|
        k, *v = *x.split('=')
        env[k] = v.join('=')
      end
      return env, args
    end

  end

end
