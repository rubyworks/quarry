module Sow

  # A Sowfile Script provides a simple DSL for specifying
  # a copylist and the various specificities needed to
  # define a scaffold generator proccess.

  class Script

    ## Script registery/
    #def self.registry
    #  @registry ||= {}
    #end

    ## If inherited, register the script by it's class basename downcased.
    ##def self.inherited(base)
    ##  registry[base.basename.downcase] = base
    ##end

    ## Specify a valid option.
    #def self.about(description=nil)
    #  @about = description if description
    #  @about
    #end

    #
    def self.utilize(name)
      require "sow/extensions/#{name}"
    end

    # Setup procedure, used to setup metadata.
    # TODO: allow there to be more than one. Then we can import other scaffolds.
    def self.setup(&block)
      define_method(:setup, &block)
    end

    # Scaffolding procedure, used to invoke #copy.
    # TODO: allow there to be more than one.
    def self.scaffold(&block)
      define_method(:scaffold, &block)
    end

    ## Specify a valid option.
    ## TODO: Store description for use in help.
    #def self.option(name, description=nil)
    #  class_eval %{
    #    def #{name}
    #      metadata.__send__('#{name}')
    #    end
    #  }
    #end

    ## Give the main argument a name.
    #def self.argument(name)
    #  define_method(name){
    #    session.argument
    #  end
    #end

    #
    def initialize(session)
      @session  = session
      @copylist = []
    end

    # Instance of Session.
    attr :session

    #
    def environment
      session.environment
    end

    #
    alias_method :env, :environment

    # Copylist contains the a list of transfer operations as 
    # compiled from the plugin.
    attr :copylist

    # Override and setup metadata and validate.
    # If something does jive, then use #abort to
    # terminate execution.
    def setup
    end

    # Override and place copy statment in this method.
    def scaffold
      copy '**/*', '.'
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

    # Designate a copying action.
    #
    # call-seq:
    #   copy(from, opts)
    #   copy(from, to, opts)
    #
    def copy(*from_to_opts)
      opts = Hash===from_to_opts.last ? from_to_opts.pop : {}
      from, to = *from_to_opts
      to = to || '.'
      @copylist << [from, to, opts.rekey(&:to_s)]
    end

=begin
    # This is to allow a plugin access to the internal state. ???
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
=end

    # If method missing, routes the call to +session+.
    def method_missing(s,*a)
      if session.respond_to?(s)
        return session.__send__(s)
      else
        super
      end
    end

    #
    def abort_unless_empty_or_managed(*ignore)
      if destination.exist?
        files = Dir.entries(destination) - (['.', '..'] + ignore)
        if !files.empty? and !managed?
          abort "This seed is intended for new projects.\n" +
                "But the destination directory is not empty.\n" +
                "Please use --force, --skip or --prompt to proceed."
        end
      end
    end

  end#class Script

  ##
  #module Plugins
  #  # see Sow::Script
  #  Script = Sow::Script
  #end

end#module Sow

