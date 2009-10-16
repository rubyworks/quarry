require 'sow/manager'
require 'facets/string/tabto'

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
    attr :argv

    # New Command.
    def initialize(argv=ARGV)
      @argv = argv.dup
    end

    # Plugin manger.
    def manager
      @manager ||= Manager.new
    end

    # Run command.
    #
    # TODO: Should we look up the directory tree for a .config/sow.yaml
    # file to determine if this has been previously sowed and maybe
    # change directory to that location?
    #
    def execute
      arguments, cooptions = *parse_argv(argv)

      # Extract standard commandline options.
      options, cooptions = standard_options(cooptions)

      if options[:help]
        puts help
        exit
      end

      # Ensure only one command type selected.
      if %{create delete update}.map{ |e| options[e.to_sym] }.compact.size > 1
        raise "Conflicting commands. Choose one: create, delete or update."
      end

      # Path to destination is the last argument, if given. Otherwise it is
      # the current working path.
      pathname = (arguments.pop || '.').chomp('/')

      options[:destination] = pathname

      # All options should appear after plugin/scaffold name.
      # however, it is able to look past purely flag switches.
      #name = arguments.find{ |e| e !~ /^\-/ }

      session = Session.new(arguments, options)

      command = session.mode

      # collect options
      options = Hash.new{ |h,k| h[k] = {} }
      cooptions.each do |(name, value)|
        if name.index('.')
          name, var = *name.split('.')
          options[name][var] = value
        else
          options[name]['argument'] = value
        end
      end

      # collect plugins
      plugins = options.map do |(name, opts)|
        # Get plugin by name
        plugin = manager.plugin(session, name, opts)
        # Setup the plugin
        plugin.setup #(command, arguments, options)
        #
        plugin
      end

      # Abort if no scaffold type given.
      if plugins.empty?
        $stderr.puts "No scaffold type given."
        exit
      end

      # Get copylists from each plugin and combine them into
      # a single compylist.
      copylist = plugins.inject([]) do |array, plugin|
        array.concat(plugin.copylist)
      end

      begin
        case command
        when :create
          generator = Generators::Create.new(session, copylist)
          generator.generate
        when :update
          generator = Generators::Update.new(session, copylist)
          generator.generate
        when :delete
          generator = Generators::Delete.new(session, copylist)
          generator.generate
        else
          raise "[IMPOSSIBLE] Unknown command type."
        end
      rescue => err
        if options[:debug]
          raise err
        else
          puts err
          puts "try --help or --debug"
          exit
        end
      end
    end

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
      opts = opts.map{ |o| o.sub(/^\-+/, '').split('=') }
      return args, opts
    end

    # Return command type based on option.
    def command(options)
      return :create if options[:create] #|| options[:c]
      return :update if options[:update] #|| options[:u]
      return :delete if options[:delete] #|| options[:d]
      nil
    end

    STANDARD_OPTIONS = {
      'create' => :create, 'c' => :create,
      'update' => :update, 'u' => :update,
      'delete' => :delete, 'd' => :delete,
      'quiet'  => :quiet , 'q' => :quiet ,
      'prompt' => :prompt, 'p' => :prompt,
      'skip'   => :skip  , 's' => :skip  ,
      'force'  => :force , 'f' => :force ,
      'trial'  => :trial , 't' => :trial ,
      'help'   => :help  , 'h' => :help  ,
      'debug'  => :debug ,
    }

    # Returns a hash of standard options and an assoc array
    # of plugin options.
    def standard_options(opts)
      h, o = {}, []
      opts.each do |(k,v)|
        if opt = STANDARD_OPTIONS[k]
          h[opt] = true
        else
          o << [k,v]
        end
      end
      return h, o
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

  end#class Command

end#module Sow

