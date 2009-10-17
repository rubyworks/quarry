require 'sow/metadata'

module Sow

  # Session provides a central store of commandline
  # options and system state related to invocation
  # the +sow+ command. This includes the destination
  # directory, it's metadata and any special sow
  # configurations.
  #
  class Session

    # Create a new session instance.

    def initialize(arguments, options)
      @arguments = arguments

      @destination = Pathname.new(options['destination'] || Dir.pwd)

      @trial  = options['trial']
      @debug  = options['debug']
      @quiet  = options['quiet']
      @force  = options['force']
      @prompt = options['prompt']
      @skip   = options['skip']

      @create = options['create']
      @update = options['update']
      @delete = options['delete']

      #options.each do |k,v|
      #  __send__("#{k}=", v) if respond_to?("#{k}=")
      #end

      if file = Dir.glob(File.join(output, '{,.}config/sow.{yml,yaml}')).first
        @config = YAML.load(File.new(file))
        @sowed = true
      else
        @config = {}
        @sowed = false
      end
    end

    #attr_writer :trial
    #attr_writer :debug
    #attr_writer :quiet
    #attr_writer :force
    #attr_writer :prompt
    #attr_writer :skip

    #attr_writer :create
    #attr_writer :update
    #attr_writer :delete

    # Destination for generated scaffolding.

    attr :destination

    # DEPREICATE: Is "output" too generic a name for a tool like Sow?

    alias_method :output, :destination

    # Tiral run? (Also know as a +noop+.)

    def trial?  ; @trial  ; end

    # Provide debugging information?

    def debug?  ; @debug  ; end

    # Run silently?

    def quiet?  ; @quiet  ; end

    # Override protected operations.

    def force?  ; @force  ; end

    # Prompot the user for options?

    def prompt? ; @prompt ; end

    # Skip overwrites?

    def skip?   ; @skip   ; end

    # Return command mode based on command options.
    # Defaults to +:create+.
    #--
    # TODO: Are their circumstances where mode should defualt to update?
    #++

    def mode
      return :create if @create
      return :update if @update
      return :delete if @delete
      return :create #sowed? ? :update : :create
    end

    # Creation mode?

    def create? ; mode == :create ; end

    # Update mode?

    def update? ; mode == :update ; end

    # Delete mode?

    def delete? ; mode == :delete ; end

    #
    #def scaffold?
    #  mode == :create && !sowed? #|| force? instad of delete and update?
    #end

    # Sow configuration.

    def config ; @config ; end

    # Previously sowed?

    def sowed? ; @sowed ; end

    # Does the destination contain any files?

    def empty?
      @empty ||= (Dir.entries(destination) - ['.', '..']).empty?
    end

    # Alias for #empty?

    alias_method :new_project?, :empty?

    # Metadata for destination, if any.
    #--
    # TODO: Use POM::Metadata in future?
    #++

    def metadata
      @metadata ||= Metadata.new(destination)
    end

    # Destination has metadata?

    def metadata?
      metadata.exist?
    end

    # What is the destinations meta directory (+meta+ or +.meta+)?
    # If none then defaults to +.meta+.

    def metadir
      @meta_directory ||= (Dir[File.join(destination, '{.meta,meta}/')].first || '.meta/').chomp('/')
    end

    # Alias for meta_directory

    alias_method :metadir, :meta_directory

  end

end
