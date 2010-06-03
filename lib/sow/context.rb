module Sow

  #FIX = "FIXME"

  # Erb templates are all rendered within the scope
  # a context object. This limits access to only
  # the those things that are pertinant. All metadata
  # can be accessded by name, as this this object
  # delegate missing methods to a Metadata instance.
  #
  class Context
    instance_methods.each{ |m| private m unless m.to_s =~ /^__/ }

    def initialize(metadata)
      @metadata = metadata
    end

    def method_missing(s)
      @metadata.__send__(s) || "___#{s}___"
    end

    # Processes file through erb.
    def erb(file)
      erb = ERB.new(File.read(file))
      erb.result(binding)
    end
  end

end
