require 'sow/manifest'
#require 'sow/metadata'
require 'sow/logger'
require 'sow/generators/create'
require 'sow/generators/update'
require 'sow/generators/delete'

module Sow

  class Plugin

    attr :location
    attr :output
    attr :runmode
    attr :arguments
    attr :options

    def initialize(location, arguments, options)
      @location = location

      @trial  = options.delete(:trial)
      @trace  = options.delete(:debug)  # FIXME: rename trace to debug
      @quiet  = options.delete(:quiet)
      @force  = options.delete(:force)
      @skip   = options.delete(:skip)
      @prompt = options.delete(:prompt)
      @output = options.delete(:output) || Dir.pwd

      delete = options.delete(:delete)
      #create = options.delete(:create)
      #update = options.delete('update') || options.delete('u')

      #if update
      #  @runmode = :update
      #create or newproject?
      #  @runmode = :create
      if delete
        @runmode = :delete
      else
        @runmode = :create
      end

      @arguments = arguments
      @options   = options
    end

    def manifest
      @manifest ||= Manifest.new(self) #(location, metadata) # <-- FIX
    end

    #def metadata
    #  @metadata ||= Metadata.new(self) #(location, output, arguments, options)
    #end

    def metadata
      @metadata ||= Metatemp.new(self) #(location, output, arguments, options)
    end

    def logger
      @logger ||= Logger.new(self)
    end

    #
    def context
      @context ||= Context.new(self, metadata)
    end

    #def execute
    #  return update if update?
    #  return create if create?
    #  return delete if delete?
    #end

    def create
      Generators::Create.new(self).generate
    end

    #def update
    #  Generators::Update.new(self).generate
    #end

    def destroy
      Generators::Delete.new(self).generate
    end

    def filter
      [ /MANIFEST\.sow$/, /USAGE\.sow$/ ]
    end

    def trial?  ; @trial  ; end
    def trace?  ; @trace  ; end
    def quiet?  ; @quiet  ; end
    def force?  ; @force  ; end
    def prompt? ; @prompt ; end
    def skip?   ; @skip   ; end

    def create?
      @runmode == :create
    end

    def delete?
      @runmode == :delete
    end

    #def update?
    #  @runmode == :update
    #end

    # New project?
    def newproject?
      @newproject ||= Dir.glob(File.join(output, '*')).empty?
    end

    # Destination has metadata?
    def metadata?
      @meta ||= ! Dir.glob(File.join(output, '{.meta,meta}/')).empty?
    end

    # What is the outputs metadirectory?
    def metadir
      @metadir ||= Dir[File.join(output, '{.meta,meta}/')].first || '.meta/'
    end

    # Processes with erb.
    def erb(file)
      context.erb(file)
    end

    def prepare
      manifest.prepare
    end

    ###
    #def erb(file)
    #  text = nil
    #  temp = Context.new(plugin)
    #  begin
    #    text = temp.erb(file)
    #  rescue => e
    #    if trace?
    #      raise e
    #    else
    #     abort "template error -- #{file}"
    #    end
    #  end
    #  return text
    #end

  end

end

