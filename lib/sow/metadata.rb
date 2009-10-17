module Sow

  # Metadata located in destination.
  #
  # This can be used to "prefill" template variables in some
  # types of scaffolding.
  #
  #--
  # TODO: Use POM::Metadata instead?
  #
  # TODO: Should this only be used when updating?
  #
  # TODO: If we copy meta/ first then it can be reused. ?
  #++
  class Metadata
    alias :__id__ :object_id

    instance_methods.each{ |m| private m unless m.to_s =~ /^__/ }

    #
    def initialize(destination)
      @dir   = destination
      @cache = {}
    end

    # Is there a metadata directory located in the destination directory?
    def exist?
      @exist ||= Dir.glob(File.join(@dir, '{.meta,meta}/')).first
    end

    # If method is missing, lookup metdata value by that name.
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

    # Metadata has given +entry+?
    def respond_to?(entry)
      self[entry] ? true : false
    end

    # Get a metadata value directly from the metadata cache.
    def __get__(entry)
      @cache[entry.to_s]
    end

    # Get a metadata value. If not found in the cache,
    # attempt to load it from the path store.
    def [](s)
      s = s.to_s
      if @cache.key?(s)
        @cache[s]
      else
        #@cache[s] = HOLE + " (#{s})"
        @cache[s] = load_value(s) #|| HOLE + " (#{s})"
      end
    end

    # Set a metadate value.
    def []=(k,v)
      @cache[k.to_s] = v
    end

  private

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

      # See if the metadata is defined in the destination.

      file = Dir[File.join(@dir, '{meta,.meta}', name)].first

      if file && File.file?(file)
        File.read(file).strip  # erb?
      else
        nil
      end
    end

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

