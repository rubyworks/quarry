require 'sow/cli/seed'

module Sow::CLI

  # Sow a new project.
  class New < Seed

    command 'new'

    #
    def call(argv)
      if argv.empty?
        FileUtils.mkdir_p(File.join(options[:output] || Dir.pwd, '.sow'))
      else
        super(argv)
      end
    end

    #
    def run(*argv)
      opts.parse!(argv)
      options[:output] = argv.shift
      raise "Directory #{options[:output]} already exists." if File.exist?(options[:output])
      call(argv)
    end

    #
    def opts
      OptionParser.new{ |o|
        o.banner = "Usage: sow new <dir> <seed> [*args]"
        o.separator "Sow seed into new directory."
        #o.on('--output', '-o PATH'){ |path| options[:output] = path }
        #o.on('--write' , '-w'){ options[:mode] = :write }
        #o.on('--prompt', '-p'){ options[:mode] = :prompt }
        #o.on('--skip'  , '-s'){ options[:mode] = :skip }
        o.on('-i', '--interactive'){ options[:interactive] = true }
        o.on('-f', '--force'      ){ $FORCE  = true }
        o.on('--dryrun'      ){ $DRYRUN = true }
        o.on('--debug'       ){ $DEBUG  = true }
        o.on('-h', '--help'  ){ puts o; exit }
      }
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
