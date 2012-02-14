require 'quarry/cli/abstract'

module Quarry::CLI

  # Quarry ore(s). This is the deafult commandline interface.
  #
  class Ore < Abstract

    command ''
    command 'ore'

    #
    def call(argv)
      templates = parse_arguments(argv)
      generator = Quarry::Generator.new(templates, options)
      generator.run!
    end

    #
    def opts
      OptionParser.new{ |o|
        o.banner = "Usage: quarry <ore> [arg ...] [key=val ...] [- <ore> ...]"
        o.separator "Mine ore."
        o.on('-o', '--output PATH'){ |path| options[:output] = path }
        o.on('-w', '--write'      ){ options[:mode] = :write }
        o.on('-p', '--prompt'     ){ options[:mode] = :prompt }
        o.on('-s', '--skip'       ){ options[:mode] = :skip }
        o.on('-i', '--interactive'){ options[:interactive] = true }
        o.on('-f', '--force' ){ $FORCE  = true }
        o.on('--dryrun'      ){ $DRYRUN = true }
        o.on('--debug'       ){ $DEBUG  = true }
        o.on('-h', '--help'  ){ puts o; exit }
      }
    end

    #
    def parse_arguments(argv)
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
        uri = arguments.shift
        [uri, arguments, settings]
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
