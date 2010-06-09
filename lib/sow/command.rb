require 'fcntl'
require 'optparse'
require 'facets/string/tabto'
require 'sow/session'

module Sow

  # Sow Commandline Utility.
  #
  # TODO: Provide help messages for individual plugins.
  #
  class Command

    # Initialize and execute command.
    def self.execute
      new.execute
    end

    # Commandline arguments.
    attr :arguments

    #
    attr :options

    # New Command.
    def initialize(argv=ARGV)
      @arguments = argv.dup
      @options   = OpenStruct.new
      @action    = nil
    end

    ## Plugin manger.
    #def manager
    #  @manager ||= Manager.new
    #end

    # Run command.
    #
    # TODO: Should we really be using ENV, or should we instead
    # manage a separate variable list?
    def execute
      opts = option_parser
      opts.parse!(arguments)

      options.copylist = extended_copylist

      #environment = {}
      arguments.reject! do |arg|
        case arg
        when /^(.*)\=(.*?)$/
          #environment[$1] = $2
          ENV[$1] = $2
          true
        else
          false
        end
      end

      resource = arguments.shift
      #destination = Dir.pwd #arguments.shift

      session = Session.new(resource, arguments, options) #environment, options)

      #session.setup

      ## collect plugins
      #plugins = options.map do |(name, opts)|
      #  # Get plugin by name
      #  plugin = manager.plugin(session, name, opts)
      #  # Setup the plugin
      #  plugin.setup #(command, arguments, options)
      #  #
      #  plugin
      #end

      ## Abort if no scaffold type given.
      #if plugins.empty?
      #  $stderr.puts "No scaffold type given."
      #  exit$stderr.puts val
      #end

      begin
        case @action
        when :help
          if resource
            puts session.readme
          else
            puts opts
          end
          exit
        when :create
          session.create
        when :delete
          session.delete
        when :install
          session.install
        when :update
          session.update
        when :uninstall
          session.uninstall
        when :list
          session.list
        when :print
          session.print
        else
          session.create
        end
      rescue => err
        if options.debug
          raise err
        else
          $stderr.puts err
          $stderr.puts "try --help or --debug"
          exit -1
        end
      end
    end

    #
    def option_parser
      OptionParser.new do |opts|

        opts.separator('COMMAND OPTIONS (choose one):')

        opts.on('--create', '-c', 'plant a seed') do
          @action = :create
        end

        opts.on('--delete', '-d', 'uproot a plant') do
          @action = :delete
        end

        opts.on('--install', '-i', 'add a new seed source (path or repo url)') do
          @action = :install
        end

        opts.on('--update', '-u', 'update a seed source') do
          @action = :update
        end

        opts.on('--remove', 'remove a seed source') do
          @action = :uninstall
        end

        opts.on('--list', 'list all available seeds') do
          @action = :list
        end

        opts.on('--extend', '-x', 'output copylist') do
          @action = :print
        end

        opts.separator('SELECTION OPTIONS (choose one):')

        opts.on('--prompt', '-p') do
          options.prompt = true
        end

        opts.on('--skip', '-s') do
          options.skip = true
        end

        opts.on('--force', '-f') do
          options.force = true
        end

        opts.separator('GENERAL OPTIONS:')

        opts.on('--output', '-o PATH', 'output directory') do |path|
          options.output = path
        end

        opts.on('--quiet', '-q', 'run silently (as much as possible)') do
          options.quiet = true
        end

        opts.on('--trial', '-t', 'no disk writes') do
          options.trial = true
        end

        opts.on('--debug', '-D', 'run in debug mode') do
          $VERBOSE = true
          $DEBUG   = true
        end

        opts.on_tail('--help', '-h', 'show this help message') do
          @action = :help
        end
      end
    end

    # If an optional copylist is padded in via a stdin or a pipe.
    def extended_copylist
      list = []
      if STDIN.fcntl(Fcntl::F_GETFL, 0) == 0
        val = STDIN.read
        if !val.empty?
          list = YAML.load(val)
        end
      end
      list
    end

  end

end

