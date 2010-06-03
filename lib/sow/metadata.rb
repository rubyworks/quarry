module Sow

  # Metadata for use by template variables.
  #
  class Metadata

    alias :__id__ :object_id

    instance_methods.each{ |m| private m unless m.to_s =~ /^__/ }

    #
    def initialize(*resources)
      @resources = resources
      @resources.concat(fallback)
      @resources.push(ENV)
      @cache = {}
    end

    # Put resource on top of lookup stack.
    def <<(resource)
      @resources.unshift(resource)
    end

    # If method is missing, lookup metdata value by that name.
    # If not found, returns a "FIXME" value.
    def method_missing(s, *a, &b)
      s = s.to_s
      if s =~ /=$/
        s = s.chomp('=')
        self[s] = a.first
      else
        s = s.chomp('?')
        self[s] #|| "___#{s}___"
      end
    end

    # Metadata has given +entry+?
    def respond_to?(entry)
      self[entry] ? true : false
    end

    # Get a metadata value. If not found return nil.
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

    def fallback
      files = XDG::Config.select('sow/metadata.yml')
      files.map do |file|
        YAML.load(File.new(file))
      end
    end

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
=end

    # Processes with erb.
    #def erb(file)
    #  erb = ERB.new(File.read(file))
    #  erb.result(binding)
    #end

  end

end

