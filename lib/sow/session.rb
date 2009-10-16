require 'sow/metadata'

module Sow

  # Session provides a central store of commandline
  # options and system state related to invocation
  # the +sow+ command. This includes the output
  # directory, it's metadata and any special sow
  # configuration.
  #
  class Session

    def initialize(arguments, options)
      @arguments   = arguments
      @destination = Pathname.new(Dir.pwd)

      #@trial  = options[:trial]
      #@debug  = options[:debug]
      #@quiet  = options[:quiet]
      #@force  = options[:force]
      #@prompt = options[:prompt]
      #@skip   = options[:skip]

      options.each do |k,v|
        __send__("#{k}=", v) if respond_to?("#{k}=")
      end

      if file = Dir.glob(File.join(output, '{,.}config/sow.{yml,yaml}')).first
        @config = YAML.load(File.new(file))
        @sowed = true
      else
        @config = {}
        @sowed = false
      end

      @empty = Dir.glob(File.join(output, '*')).empty?
    end

    attr_writer :trial
    attr_writer :debug
    attr_writer :quiet
    attr_writer :force
    attr_writer :prompt
    attr_writer :skip

    attr_writer :create
    attr_writer :update
    attr_writer :delete

    attr_reader :destination

    # deprecate
    alias_method :output, :destination

    def trial?  ; @trial  ; end
    def debug?  ; @debug  ; end
    def quiet?  ; @quiet  ; end
    def force?  ; @force  ; end
    def prompt? ; @prompt ; end
    def skip?   ; @skip   ; end

    # Return command mode based on options.
    #
    # TODO: Are their circumstances where mode should defualt to update?
    #
    def mode
      return :create if @create
      return :update if @update
      return :delete if @delete
      return :create #sowed? ? :update : :create
    end

    #
    def destination=(path)
      @destination = Pathname.new(path)
    end

    #
    #def scaffold?
    #  mode == :create && !sowed? #|| force? instad of delete and update?
    #end

    # Sow configuration.
    def config ; @config ; end

    # Previously sowed?
    def sowed? ; @sowed ; end

    # New project?
    def empty?
      @empty
    end

    # DEPRECATE
    alias_method :newproject?, :empty?

    #
    def metadata
      @metadata ||= Metadata.new(output)
    end

    # Destination has metadata?
    def metadata?
      @metadata_Q ||= ! Dir.glob(File.join(output, '{.meta,meta}/')).empty?
    end

    # What is the outputs metadirectory?
    def metadirectory
      @metadirectory ||= Dir[File.join(output, '{.meta,meta}/')].first || '.meta/'
    end

    #
    alias_method :metadir, :metadirectory

    #
    def create? ; @mode == :create ; end
    def update? ; @mode == :update ; end
    def delete? ; @mode == :delete ; end

  end

end

