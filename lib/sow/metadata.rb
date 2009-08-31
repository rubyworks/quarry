module Sow

  # Metadata in destination.
  #
  # This can be used to "prefill" some types of scaffolding.
  #
  class Metadata
    instance_methods.each{ |m| private m unless m.to_s =~ /^__/ }

    HOLE = "__FIX__"

    def initialize(output)
      #@location  = location
      @output    = output
      @cache     = {}
    end

    #
    def method_missing(s, *a, &b)
      s = s.to_s
      if s =~ /=$/
        s = s.chomp('=')
        self[s] = a[0]
      else
        s = s.chomp('?')
        self[s]
      end
    end

    #
    def [](s)
      s = s.to_s
      if @cache.key?(s)
        @cache[s]
      else
        @cache[s] = HOLE
        @cache[s] = load_value(s) || HOLE
      end
    end

    #
    def []=(k,v)
      @cache[k.to_s] = v
    end

  private

    # Metadata directory in output location.
    #def metafolder
    #  @metafolder ||= Dir[File.join(@output, '{.meta,meta}')].first
    #end

    # Load metadata value.
    #
    # In update mode, metadata is looked for in the receiving end.
    #
    def load_value(name)
      #val = read_value_from_commandline(name)
      #return val if val

      #if @plugin.update?
      #  val = load_value_from_destination(name)
      #  return val if val
      #end

      # See if the metadata is already defined in the destination.
      # TODO: Should this only be used when updating?
      file = Dir[File.join(@output, '{meta,.meta}', name)].first
      if file && File.file?(file)
        return File.read(file).strip
      end

# NOTE: If we copy meta/ first then it can be reused. ?

      # See if it is defined in the source location.
      #file = Dir[File.join(@location, '{meta,.meta}', name)].first
      #if file && File.file?(file)
      #  return erb(file).strip
      #end

      # Otherwise return nil.
      return nil
    end

    #
    #def read_value_from_commandline(name)
    #  @plugin.manifest.argv[name.to_sym]
    #  #@plugin.options[name]
    #end

    #def load_template_metadata
    #  Dir[File.join(metasrc, '*')].each do |f|
    #    @metadata_source[File.basename(f)] = erb(f).strip
    #  end
    #end

    # Processes with erb.
    def erb(file)
      erb = ERB.new(File.read(file))
      erb.result(binding!)
    end

    def binding!
      binding
    end

  end

end


=begin

  #
  class Metatemp

    HOLE = "__FIX__"

    attr :arguments
    attr :options

    def initialize(output) #location, output, arguments, options={})
      #@plugin    = plugin
      #@location  = plugin.location

      @output    = output

      #@arguments = plugin.arguments
      #@options   = plugin.options

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
        s = s.chomp('=')
        self[s] = a[0]
      else
        s = s.chomp('?')
        self[s]
      end
      #val = @instance_delegate.send(s, *a, &b)
    end

    def [](s)
      s = s.to_s
      if @cache.key?(s)
        @cache[s]
      else
        @cache[s] = HOLE
        @cache[s] = load_value(s.to_s) || HOLE
      end
    end

    def []=(k,v)
      @cache[k.to_s] = k
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

    # Metadata directory in output location.
    #def metafolder
    #  @metafolder ||= Dir[File.join(@output, '{.meta,meta}')].first
    #end

    # Load metadata value.
    #
    # In update mode, metadata is looked for in the receiving end.
    #
    def load_value(name)
      #val = read_value_from_commandline(name)

      #return val if val

      #if @plugin.update?
      #  val = load_value_from_destination(name)
      #  return val if val
      #end

      #@metadata_source[name]

      #file = File.join(metasrc, name)

      file = Dir[File.join(@output, '{meta,.meta}', file)].first

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
=end

