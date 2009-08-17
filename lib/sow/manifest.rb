module Sow

  # A Sow manifest is a simple DSL the specifies acceptable
  # arguments and options and a copy list. The file must be
  # named MANIFEST.sow.
  #
  class Manifest

    attr :plugin
    attr :location
    attr :metadata

    attr :arguments
    attr :options
    attr :copylist

    #attr :argv

    #
    def initialize(plugin) #location, metadata)
      @plugin    = plugin
      @location  = plugin.location
      @metadata  = plugin.metadata

      @arguments = []
      @options   = []
      @manifest  = []
      @copylist  = []

      #@argv = {}
      #@argc = -1

      read_manifest_file
    end

    #
    def read_manifest_file
      file   = File.join(location, 'MANIFEST.sow')
      script = File.read(file)
      instance_eval(script, file)
    end

    def argument(name, desc=nil, &valid)
      @arguments << [name, valid]
      #argv[name] = plugin.arguments[@argc+=1]
      #valid.call(argv[name]) if valid
      #define_method(name) do
      #  plugin.arguments[i]
      #end
    end

    def option(name, desc=nil, &valid)
      @options << [name, valid]
    end

    def manifest(&block)
      @manifest << block
    end

    def copy(from, to, opts={})
      @copylist << [from, to, opts]
    end

    def prepare
      @manifest.each do |m|
        m.call
      end
    end

    def argv
      @argv ||= (
        h = {}
        @arguments.each_with_index do |(name, valid), i|
          h[name] = plugin.arguments[i]
          valid.call(h[name]) if valid
        end
        h
      )
    end

    def metadir
      @plugin.metadir
    end

  end

end

