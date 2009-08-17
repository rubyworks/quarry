module Sow

  class Context
    def initialize(plugin, meta)
      @plugin = plugin
      @meta = meta
    end

    def method_missing(s)
      @meta.send(s)
    end

    # Processes file through erb.
    def erb(file)
      erb = ERB.new(File.read(file))
      erb.result(binding)
    end
  end

  #
  class Metatemp

    HOLE = "__FIX__"

    attr :arguments
    attr :options

    def initialize(plugin) #location, output, arguments, options={})
      @plugin    = plugin

      @location  = plugin.location
      #@output    = plugin.output

      @arguments = plugin.arguments
      @options   = plugin.options

      @cache     = {}

      #@argcnt = -1

      #if options[:no_pom]
      #  @instance_delegate = OpenStruct.new
      #else
      #  @instance_delegate = Pom::Metadata.new(location)
      #end

      #if Dir[File.join(output, '{.meta,meta}/')].first
      #Pom::Metadata.new

      #@metadata_source = {}
      #load_template_metadata
    end

    def method_missing(s, *a, &b)
      s = s.to_s
      if s =~ /=$/
        @cache[s] = a[0]
      else
        s = s.chomp('?')
        if @cache.key?(s)
          @cache[s]
        else
          @cache[s] = HOLE
          @cache[s] = load_value(s.to_s) || HOLE
        end
      end
      #val = @instance_delegate.send(s, *a, &b)
    end

    def metadir
      @plugin.metadir
    end

    #
    #def argument(number, name, &validate) #, *aliae)
    #  number = number.to_i
    #  name   = name.to_s
    #  if @plugin.update?
    #    val = load_value_from_destination(name)
    #    return val if val
    #  end
    #  val = arguments[number-1] || options[name]
    #  raise ArgumentError, "#{name} argument required" unless val
    #  raise ArgumentError, "invalid #{name}" unless validate[val] if validate
    #  val
    #end

  private

    # Metadata directory in source location.
    def metasrc
      @metasrc ||= Dir[File.join(@location, '{META,.meta,meta}')].first
    end

    # Load metadata value.
    #
    # In update mode, metadata is looked for in the receiving end.
    # 
    def load_value(name)
      val = read_value_from_commandline(name)

      return val if val

      #if @plugin.update?
      #  val = load_value_from_destination(name)
      #  return val if val
      #end

      #@metadata_source[name]

      file = File.join(metasrc, name)
      file = Dir[file].first
      if file && File.file?(file)
        return erb(file).strip
      end

      nil
    end

    #
    def read_value_from_commandline(name)
      @plugin.manifest.argv[name.to_sym]
      #@plugin.options[name]
    end

    #def load_template_metadata
    #  Dir[File.join(metasrc, '*')].each do |f|
    #    @metadata_source[File.basename(f)] = erb(f).strip
    #  end
    #end

    # Processes with erb.
    def erb(file)
      erb = ERB.new(File.read(file))
      txt = erb.result(binding!)
    end

    def binding!
      binding
    end

  end

end

