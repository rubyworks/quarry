module Sow

  # Metadata for use by template variables in some
  # types of scaffolding.
  #
  #--
  # TODO: Should this only be used when updating?
  #
  # TODO: If we copy PROFILE first then it can be reused. ?
  #
  # TODO: Use ~/.config/sow/meta.yml and env as fallbacks.
  #++

  class Metadata
    alias :__id__ :object_id

    instance_methods.each{ |m| private m unless m.to_s =~ /^__/ }

    #
    def initialize(*resources)
      @resources = resources
      @resources << ENV
      @cache = {}
    end

    #
    def <<(resource)
      @resources << resource
    end

    # If method is missing, lookup metdata value by that name.
    def method_missing(s, *a, &b)
      s = s.to_s
      if s =~ /=$/
        s = s.chomp('=')
        self[s] = a.first
      else
        s = s.chomp('?')
        self[s] || "FIXME ___#{s}___"
      end
    end

    # Metadata has given +entry+?
    def respond_to?(entry)
      self[entry] ? true : false
    end

    # Get a metadata value. If not found in the cache return
    # a "FIXME" value.
    def [](s)
      s = s.to_s
      if @cache.key?(s)
        @cache[s]
      else
        val = lookup(s)
        if val
          @cache[s]= val
        else
          @cache[s] = nil
          #@cache[s] = load_value(s) #|| HOLE + " (#{s})"
        end
      end
    end

    # Set a metadate value.
    def []=(k,v)
      @cache[k.to_s] = v
    end

    #
    def lookup(name)
      result = false
      @resources.find do |resource|
        case resource
        when ENV
          result = resource[name.to_s]
        when Hash, OpenStruct
          result = resource[name.to_s] || resource[name.to_sym]
        else
          if resource.respond_to?(name)
            result = resource.__send__(name)
          else
            result = false
          end
        end
      end
      result
    end

    # Get a metadata value directly from the metadata cache.
    def __get__(entry)
      @cache[entry.to_s]
    end

  private

=begin
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
=end

  end

end

