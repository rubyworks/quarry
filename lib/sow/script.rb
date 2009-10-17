module Sow

  # A Sow Script provides a simple DSL for specifying
  # arguments, a copylist and the various specificities
  # needed to define a scaffold generator proccess.
  #
  # Note: This is the old way of building a plugin.

  class Script

    # Script registery/

    def self.registry
      @registry ||= {}
    end

    # If inherited, register the script by it's class basename downcased.

    def self.inherited(base)
      registry[base.basename.downcase] = base
    end

    # Setup procedure, used to setup metadata.

    def self.setup(&block)
      define_method(:setup,&block)
    end

    # Manifest procedure, used to invoke #copy.

    def self.manifest(&block)
      define_method(:manifest,&block)
    end

    # Specify a valid option.

    def self.option(name)
      attr_accessor(name)
    end

    # Give the main argument a name.

    def self.argument(name)
      define_method(name){ argument }
    end

    # Override and setup metadata and validate.
    # If something does jive, then use #abort to
    # terminate execution.
    def setup
    end

    # Override and place copy statment in this method.
    #
    def manifest
      copy '**/*', '.'
    end

    # Instance of Session.

    attr :session

    #

    attr :options

    # Copylist contains the a list of transfire operations as 
    # compiled from the plugin.

    attr :copylist

    #
    def initialize(session, options)
      @session = session
      @options = options

      #@location = Pathname.new(location)
      @metadata = OpenStruct.new

      @copylist  = []
    end

    # Main argument.

    def argument
      options.argument
    end

    # Access to Metadata. When the script is initially executed,
    # ie. toplevel and argument blocks, this is an OpenStruct.
    # Use it to assign values to the metadata, which is used to
    # render the file templates. When the scaffold block is
    # finally executed, this is reassigned to the destinations
    # metadata, so that it can be used in the copy calls, if
    # needed.

    def metadata
      session.metadata
    end

    # Destiation pathname. This is used by some plugins,
    # particularly full-project scaffolds, as a default
    # package name. It is the basename of the output directory.

    def destination
      session.destination
    end

    #def values
    #  @values
    #end

    #def location=(path)
    #  @location = Pathname.new(path)
    #end

    # Describe the purpose of this generator.
    #def about(text)www.google.com/ig?hl=en
    #  @about = text
    #end

    # Give a one line usage template.
    # Eg. '--reap=<name>'
    # "Usage: sow" is automatically prefixed to this.
    #def usage(usage)
    #  @usage = usage
    #end

    # Define the commandline argument.
    #def argument(name, desc=nil, &valid)
    #  @arguments << [name, desc, valid]
    #  #argv[name] = @arguments[@argc+=1]
    #  #valid.call(argv[name]) if valid
    #  #define_method(name) do
    #  #  @arguments[i]
    #  #end
    #end

    #def option(name, desc=nil, &valid)
    #  @options << [name, desc, valid]
    #end

    # This called with a +block+ in ones plugin script
    # containing #copy calls for specifying the scaffold
    # generation. While #copy can be called at the toplevel,
    # this allows for delayed processing until metadata is
    # avaiable.
    #def scaffold(&block)
    #  @copytemp << block
    #end

    # Designate a copying action.
    #   copy from, opts
    #   copy from, to, opts
    #
    def copy(*from_to_opts)
      opts = Hash===from_to_opts.last ? from_to_opts.pop : {}
      from, to = *from_to_opts
      to = to || '.'
      @copylist << [from, to, opts.rekey(&:to_s)]
    end

    #
    #def metafolder
    #  @metafolder
    #end

    # This is to allow Plugin access to the internal state.
    def [](var)
      instance_variable_get("@#{var}")
    end

    # Set ... using a singleton method.
    def []=(var, val)
      quaclass = (class << self; self; end)
      raise "invalid argument name -- #{var}" if quaclass.method_defined?(var)
      quaclass.class_eval do
        define_method(var){ val }
      end
      #@session[var.to_sym] = val
    end

    # If method missing, routes the call to +session+.
    def method_missing(var,*a)
      if val = @session.__send__(var)
        return val
      else
        super
      end
    end

  end#class Script

  #
  module Plugins
    # see Sow::Script
    Script = Sow::Script
  end

end#module Sow

