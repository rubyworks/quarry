require 'plugin'
require 'xdg'
require 'facets/pathname'
require 'facets/ostruct'

require 'sow/metadata'
require 'sow/scaffold'
require 'sow/manager'

module Sow

  # Session provides a central store of commandline
  # options and system state related to invocation
  # the +sow+ command. This includes the destination
  # directory, it's metadata and any special sow
  # configurations.
  #
  class Session

    SOURCE_DIRS = XDG::Config.select('/sow/sources/')

    # Create a new session instance.
    def initialize(resource, destination, environment, options)
      @resource  = resource

      @options     = OpenStruct.new(options)
      @environment = OpenStruct.new(environment)

      @destination = (
        if destination
          Pathname.new(destination)
        else
          Pathname.new(Dir.pwd)
        end
      )
    end

    #
    attr :resource

    #
    def scaffold
      @scaffold
    end

    #
    def copylist
      @scaffold.copylist
    end

    #
    def generator
      @generator ||= (
        case action.to_sym
        when :create
          Generators::Create.new(self, copylist)
        when :update
          Generators::Update.new(self, copylist)
        when :delete
          Generators::Delete.new(self, copylist)
        else
          raise "Unknown command type."
        end
      )
    end

    #
    def run
      case action.to_sym
      when :install
        manager.install(resource)
      when :uninstall
        manager.uninstall(resource)
      else
        setup_scaffold
        generator.generate
      end
    end

    #
    def setup_scaffold
      @location  = manager.find_scaffold(resource)

      if file = @destination.glob('{,.}config/sow.{yml,yaml}').first
        @config = YAML.load(File.new(file))
        @sowed  = true
      else
        @config = {}
        @sowed  = false
      end

      @scaffold = Scaffold.new(self)
    end

  public

    # Location of scaffolding.
    attr :location

    # Destination for generated scaffolding.
    attr :destination

    # Environment settings.
    attr :environment

    # Commandline options.
    attr :options

    # DEPRICATE: Is "output" too generic a name for a tool like Sow?
    alias_method :output, :destination

    # Tiral run? (Also know as a +noop+.)
    def trial?
      @options.trial
    end

    # Provide debugging information?
    def debug?
      $DEBUG #@options.debug
    end

    # Run silently?
    def quiet?
      @options.quiet
    end

    # Override protected operations.
    def force?
      @options.force
    end

    # Prompot the user for options?
    def prompt?
      @options.prompt
    end

    # Skip overwrites?
    def skip?
      @options.skip
    end

    # Return command mode based on command options.
    # Defaults to +:create+.
    #--
    # TODO: Are their circumstances where mode should defualt to update?
    #++

    def action
      @options.action || :create  #sowed? ? :update : :create
    end
    alias_method :mode, :action

    def update?
      action == :update
    end

    def create?
      action == :create
    end

    def delete?
      action == :delete
    end

    def managed?
      force? or skip? or prompt?
    end

    #
    #def scaffold?
    #  mode == :create && !sowed? #|| force? instad of delete and update?
    #end

    # Sow configuration.
    def config
      @config
    end

    # Previously sowed?
    def sowed?
      @sowed
    end

    # Does the destination contain any files?
    def empty?
      @empty ||= Dir[destination + '*'].empty?
    end

    # Alias for #empty?
    alias_method :new?, :empty?

    # Metadata for destination, if any.
    #--
    # TODO: Use POM::Metadata in future?
    #++
    def metadata
      @metadata ||= Metadata.new(environment)
    end

    # Destination has metadata?
    def metadata?
      metadata.exist?
    end

    ## What is the destinations meta directory (+meta+ or +.meta+)?
    ## If none then defaults to +.meta+.
    #def metadir
    #  @meta_directory ||= (Dir[File.join(destination, '{.meta,meta}/')].first || '.meta/').chomp('/')
    #end

    ## Alias for meta_directory
    ##alias_method :metadir, :meta_directory

    #
    def manager
      @manager ||= Manager.new(options)
    end

    #
    def sources
      manager.sources
    end

  end

end

