require 'facets/argvector' # TODO: replace with Clio::Usage
require 'sow/manager'

module Sow

  class Command

    def self.run
      new.run
    end

    attr :cmd
    attr :args
    attr :opts

    #
    def initialize(argv=ARGV)
      cli = Argvector.new(argv)

      @cmd, @args, @opts = *cli.subcommand

      #@use['--help -h', "Display this help infromation"]

      #@use['--create -c', "Create scaffolding (default)"]
      #@use['--update -u', "Update scaffolding (default)"]
      #@use['--delete -d', "Delete scaffolding (default)"]

      #@use['--output=PATH -o', "Output directory [.]"]

      #manager.plugins.each do |name|
      #  @use.subcommand(name)
      #end
    end

    #
    def manager
      @manager ||= Manager.new
    end

    #
    def run
      name = cmd

      if opts['help'] || opts['h']
        if name
          puts "help to do #{name}"
        else
          puts "help to do"
        end
        exit
      end

      del = opts['d'] || opts['delete']

      unless name
        puts "Scaffold name required."
        exit
      end

      command = del ? :delete : :create
      arguments = [name]

      begin
        send(command, *arguments)
      rescue => err
        if trace?
          raise err
        else
          puts err
          puts "try --help or --trace"
          exit
        end
      end

    end

    def create(name)
      plugin = manager.plugin(name, @args, @opts.dup)
      plugin.create
    end

    def delete(name)
      plugin = manager.plugin(name, @args, @opts.dup)
      plugin.delete
    end

    def trace?
      @opts['trace']
    end

  end

end

