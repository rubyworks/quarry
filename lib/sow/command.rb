require 'sow/session'
require 'facets/string/tabto'
require 'optparse'

module Sow

  # Sow Commandline Utility.
  #
  # TODO: Provide help messages for individual plugins.
  #
  # TODO: Move the core logic of execture to either Manger or another class.
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
    # TODO: Should we look up the directory tree for a .config/sow.yaml
    # file to determine if this has been previously sowed and maybe
    # change directory to that location?
    #
    # TODO: instead of a separate environment variable, add them to 
    # ENV['sow_name'] ?
    #
    def execute
      opts = option_parser
      opts.parse!(arguments)

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
      #  exit
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

        opts.on('--create', '-c') do
          @action = :create
        end

        opts.on('--delete', '-d') do
          @action = :delete
        end

        opts.on('--install', '-i', "add a new source location/repository") do
          @action = :install
        end

        opts.on('--update', '-u') do
          @action = :update
        end

        opts.on('--remove', "remove a source location/repository") do
          @action = :uninstall
        end

        opts.on('--list') do
          @action = :list
        end

        opts.on('--prompt', '-p') do
          options.prompt = true
        end

        opts.on('--skip', '-s') do
          options.skip = true
        end

        opts.on('--force', '-f') do
          options.force = true
        end

        opts.on('--quiet', '-q') do
          options.quiet = true
        end

        opts.on('--trial', '-t') do
          options.trial = true
        end

        opts.on('--output', '-o PATH', 'output directory') do |path|
          options.output = path
        end

        opts.on('--debug', '-D') do
          $VERBOSE = true
          $DEBUG   = true
        end

        opts.on_tail('--help', '-h', 'show this help message') do
          @action = :help
        end
      end
    end

  end

end









=begin
    # Very simply ARGV parser. In the future we may make
    # this a bit smarter. We do it manually to preserve the
    # order of plugin options.
    def parse_argv(argv)
      args = []
      opts = []
      argv.each_with_index do |arg, idx|
        case arg
        when /^-/
          opts << arg
        else
          args << arg
        end
      end
      opts = opts.map{ |          $DEBUG = trueo| o.sub(/^\-+/, '').split('=') }
      return args, opts
    end


    # Return command type based on option.
    #def command(options)
    #  return 'create' if options['create'] #|| options[:c]
    #  return 'update' if options['update'] #|| options[:u]
    #  return 'delete' if options['delete'] #|| options[:d]
    #  nil
    #end

    STANDARD_OPTIONS = {
      'create' => 'create', 'c' => 'create',
      'update' => 'update', 'u' => 'update',
      'delete' => 'delete', 'd' => 'delete',
      'quiet'  => 'quiet' , 'q' => 'quiet' ,
      'prompt' => 'prompt', 'p' => 'prompt',
      'skip'   => 'skip'  , 's' => 'skip'  ,
      'force'  => 'force' , 'f' => 'force' ,
      'trial'  => 'trial' , 't' => 'trial' ,
      'help'   => 'help'  , 'h' => 'help'  ,
      'debug'  => 'debug' ,
    }


    # Returns am OpenStruct of standard options and one
    # for the scaffold's options.
    def split_options(opts)
      h, s = OpenStruct.new, OpenStruct.new
      opts.each do |(k,v)|
        if opt = STANDARD_OPTIONS[k]
          h[opt+'?'] = true
        else
          s[k] = v
        end
      end
      return h, s
    end

    # General help message.
    def help
      <<-END.tabto(0)
      Usage: sow [options] --<plugin>[=<value>] ... [<path>]

      Options:
        -c --create         Create scaffolding
        -u --update         Update scaffolding
        -d --delete         Delete scaffolding
        -p --prompt         Prompt on overwrites
        -s --skip           Skip overwrites
        -f --force          Force restricted operations
        -q --quiet          Supress output messages
        -t --trial          Trial run (won't write to disk)
           --debug          Provide debuging information
        -h --help           Show this message
      END
    end
=end

