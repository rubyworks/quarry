require 'erb'
require 'plugin'
require 'sow/core_ext'
require 'sow/config'
require 'sow/manager'

module Sow

  #
  class Seed

    # Find a seed by +name+.
    def self.find(name)
      manager.find_seed(name)
    end

    # Reterun an instance of a seed manager.
    def self.manager
      @manager ||= Manager.new
    end

    # New Seed.
    #
    # name      - name of the seed (or best prefix match)
    # arguments - additional arguments for the seed
    # settings  - overriding metadata for the seed
    # options   - additional processing options
    #
    def initialize(name, arguments, settings, options)
      @name        = name
      @arguments   = arguments
      @settings    = settings || {}
      @options     = options.to_ostruct

      @source  = self.class.find(name)

      raise "No seed -- #{name}" unless @source

      @sowfile = (@source + 'Sowfile').to_s
      @sowcode = File.read(@sowfile).strip
      @sowcode = "copy all" if @sowcode.empty?
    end

    # Name of seed.
    def name ; @name ; end

    # Arguments (from commandline).
    def arguments ; @arguments ; end

    # Metadata settings (from commandline).
    def settings; @settings ; end

    #
    def options; @options ; end

    # Seed's source directory.
    def source_directory
      @source
    end
    alias_method :source, :source_directory

    # Seed's template directory. The directory must be
    # name `template` or `templates`.
    def template_directory
      @template ||= source.glob('template{,s}').first
    end

    #
    def destination_directory
      @destination ||= (options.output || Dir.pwd)
    end

    # Do it!
    def sow!(stage)
      sower = Sower.new(self)
      Dir.chdir(stage) do
        #sower.instance_eval(@sowcode, @sowfile.to_s)
        eval(@sowcode, sower.to_binding, @sowfile.to_s)
      end
    end

  end

  # Evaluation context for a seed's Sowfile.
  class Sower

    # New seed.
    def initialize(seed)
      @seed   = seed
      @empty  = Dir['*'].empty?
      @offset = nil
    end

    # The seed object.
    def seed
      @seed
    end

    # Basename of output destination directory.
    def destname
      @destname ||= (
        File.basename((seed.options.output || Dir.pwd).chomp('/'))
      )
    end

    # TODO: Make extensions plugable?
    def utilize(libname)
      require "sow/extensions/#{libname}"
    end

    # Name of the seed.
    #def name
    #  seed.name
    #end

    # Arguments (from commandline).
    def arguments
      seed.arguments
    end

    # Metadata settings (from commandline).
    def settings
      seed.settings
    end

    # Basenames of files to ignore in template files.
    IGNORE = %w{. .. .svn}

    #
    def template_directory
      seed.template_directory
    end

    # Returns the list of template files.
    def template_files
      @template_files ||= (
        files = []
        Dir.recurse(seed.template_directory.to_s) do |path|
          next if IGNORE.include?(File.basename(path))
          files << path.sub(seed.template_directory.to_s+'/','')
        end
        files
      )
    end
    alias_method(:all, :template_files)

    # Give a commandline argument a name, assign it to
    # metadata and shift it off the arguments list.
    # If the argument is nil, fallback to :default option.
    #
    # This is equivalent to:
    #
    #   metadata.<name> = arguments.shift || default
    #
    def argument(name, options={})
      value = arguments.shift || options[:default]
      metadata[name] = value if value
    end

    # Does the destination contain any files?
    def empty?
      @empty
    end

    # Metadata access, returns values from config metadata, 
    # ENV and POM metadata.
    def metadata
      @metadata ||= Metadata.new(self)
    end

    #
    def config
      @config ||= Config.new(Dir.pwd)
    end

    # Make directory. This will auto-create subdirecties,
    # equivalent to `mkdir -p`.
    def mkdir(dir)
      fileutils.mkdir_p(dir) unless File.directory?(dir)
    end

    # Append +text+ to the end of a +file+.
    def append(file, text)
      # cow procedure
      if !File.exist?(file)
        mkdir(File.dirname(file))
        if File.exist?(seed.destination_directory + file)
          fileutils.cp(seed.destination_directory + file, file)
        end
      end
      # append text to file
      File.open(file, 'a'){ |f| f << text.to_s }
    end

    # Copy a template file or a glob of template files. Except for specially
    # recognized files (.png, .jpg, etc.) all files will be run thru ERB.
    # The extension `.verbatim` can be used to prevent this and instead copied
    # verbatim --e.g. `foo.erb.verbatim` will result in `foo.erb`.
    def copy(from, to=nil, mode=nil)
      mode, to = to, nil if Integer===to

      tmpl = seed.template_directory

      list = []

      if from.index('//')
        d, f = *file.split('//')
        (tmpl + d).glob_relative(f).each do |x|
          list << [File.join(d, x), x.to_s]
        end
      else
        tmpl.glob_relative(from).each do |x|
          list << [x.to_s, x.to_s]
        end
      end

      if to
        list.map{ |from, fname| [from, File.join(to,fname)] }
      end

      list.each do |from, fname|
        template(from, fname, mode)
      end
    end

    # Copy template file to +fname+ with +mode+.
    # Or create template directory as +fname+ with +mode+.
    def template(from, fname, mode=nil)
      from  = seed.template_directory + from
      fname = fill_in_the_blanks(fname)
      if from.directory?
        mkdir(fname)
      else
        if template?(fname)
          #fname  = fname.chomp('.erb')
          result = erb(File.new(from))
          parent = File.dirname(fname)
          mkdir(parent)
          File.open(fname, 'w'){|f| f << result.to_s}
          fileutils.chmod(mode, fname) if mode
        else
          fname = fname.chomp('.verbatim')
          opts = mode ? {:mode=>mode} : {}
          fileutils.install(from, fname, opts)
        end
      end
    end

    # Run String or IO through ERB.
    def erb(io)
      case io
      when String
        text = io.to_s
      else
        text = io.read
        io.close
      end
      context = Context.new(metadata)  # TODO: Do we need a new context every time?
      ERB.new(text).result(context.to_binding)
    end

    #
    VERBATIM_EXTENSIONS = %w{.jpg .png .gif .pdf .ogv .ogg}

    # Should a given file be processed as a template (via ERB).
    def template?(file)
      case File.extname(file)
      when '.erb'
        true
      when '.verbatim'
        false
      when *VERBATIM_EXTENSIONS
        false
      else
        true
      end
    end

    # Import another seed. Be specific about the seed name when using this.
    def import(name)
      Seed.new(name).sow!(Dir.pwd)
    end

    # File names can have __name__ style variables to
    # be filed in by metadata. This method handles the
    # substituion.
    def fill_in_the_blanks(string)
      string.gsub(/__(.*?)__/) do |match|
        metadata[$1]
      end
    end

    # Abort if destination is not empty, less ignored files.
    # This method acts as a precaution for seeds that are 
    # intended to be used to create new projects.
    #
    # The user can override this check with the --force option.
    #
    # TODO: Probably should not be using global $FORCE variable.
    def ensure_empty(*ignore)
      files = Dir.entries(Dir.pwd) - (['.', '..'] + ignore)
      if !files.empty? and !$FORCE
        raise "This seed is intended for new projects.\n" +
              "But the destination directory is not empty.\n" +
              "Please use --force option to proceed."
      end
    end

    #
    def fileutils
      FileUtils
    end

    #
    def scaffold(&block)
      Scaffold.new(self, &block).commit!
    end

    #
    def to_binding
      binding
    end

    # Encapsulate a set of copy transactions.
    class Scaffold

      attr :sower

      attr :copylist

      #
      def initialize(sower, &block)
        @sower       = sower
        @copy_list   = {}
        @append_list = {}
        instance_eval(&block)
      end

      #
      def copy(from, to=nil, mode=nil)
        mode, to = to, nil if Integer===to

        tmpl = sower.seed.template_directory

        list = []

        if from.index('//')
          d, f = *from.split('//')
          (tmpl + d).glob_relative(f).each do |x|
            list << [File.join(d, x), x.to_s]
          end
        else
          tmpl.glob_relative(from).each do |x|
            list << [x.to_s, x.to_s]
          end
        end

        if to
          list = list.map{ |from, fname| [from, File.join(to,fname)] }
        end

        list.each do |from, fname|
          @copy_list[fname] = [from, mode]
        end
      end

      #
      def append(file, text)
        @append_list << [file, text]
      end

      # Copies occur before appends.
      def commit!
        @copy_list.each do |fname, (from, mode)|
          sower.template(from, fname, mode)
        end
        @append_list.each do |file, text|
          sower.append(file, text)
        end
      end
    end

    # Metdata access for filing in template slots.
    class Metadata
      alias_method :__class__, :class
      instance_methods.each{ |m| undef_method(m) unless m.to_s =~ /^__/ }

      #
      def initialize(seed)
        @seed = seed
        @data = {}
      end

      # TODO: Need to make sources more easily adjustable for use with POM extension.
      def metadata_sources
        [@data, @seed.settings, @seed.config, ENV]
      end

      # Get metadata entry.
      def [](name)
        name = name.to_s
        if src = metadata_sources.find{ |s| s.key?(name) }   # s && s.key?
          src[name]
        else
          nil
        end
      end

      # Set metadata entry.
      def []=(name, value)
        @data[name.to_s] = value
      end

      #
      def method_missing(sym, *args)
        sym = sym.to_s
        case sym
        when /\=$/
          name = sym.chomp('=')
          @data[name] = args.first
        when /\?$/
          self[sym.chomp('?')]
        when /\!$/
          # TODO: if method_missing ends in '!'
        else
          self[sym]
        end
      end
    end

    #
    class Context
      #
      def initialize(metadata)
        @metadata = metadata
      end
      #
      def method_missing(s, *a, &b)
        @metadata[s.to_s] || "__#{s}__"
      end
      #
      def to_binding
        binding
      end
    end

  end

end

