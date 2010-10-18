#require 'erb'
require 'malt'
require 'fileutils'
require 'tmpdir'
require 'sow/seed'
require 'sow/copier'

module Sow

  # Evaluation context for a seed's Sowfile, which "sows" the seed's template
  # files to a staging ground.
  # 
  class SowerEval

    #
    def initialize(seed, options)
      @seed      = seed

      @output    = Pathname.new(options[:output] || Dir.pwd)
      @work_path = Pathname.new(Dir.pwd)
    end

    #
    def sow!(stage)
      Dir.chdir(stage) do
        instance_eval(seed.script, seed.sowfile)
      end
    end

    # The seed object.
    def seed
      @seed
    end

    # Basename of output destination directory.
    #def destname
    #  @destname ||= (
    #    File.basename((seed.options.output || Dir.pwd).chomp('/'))
    #  )
    #end

    # TODO: Make extensions plugable?
    def utilize(libname)
      require "sow/extensions/#{libname}"
    end

    #
    def seed
      @seed
    end

    # Name of the seed.
    def name
      seed.name
    end

    # Arguments (from commandline).
    def arguments
      seed.arguments
    end

    # Metadata settings (from commandline).
    def settings
      seed.settings
    end

    # Output directory.
    def output
      @output
    end

    # Current working directory.
    def work_path
      @work_path
    end

    #def stage_path
    #  @stage_path
    #end

    # Give a commandline argument a name, assign it to
    # metadata and shift it off the arguments list.
    # If the argument is nil, fallback to :default option.
    #
    # This is equivalent to:
    #
    #   metadata.<name> = arguments.shift || default
    #
    def argument(name, options={})
      value = arguments.shift || metadata[name] || options[:default]
      metadata[name] = value if value
    end

    # Does the output directory contain any files?
    def empty?
      output.children.empty?
    end

    # Metadata access, returns values from config metadata, 
    # ENV and POM metadata.
    def metadata
      @metadata ||= Metadata.new(self)
    end

    #def template_files
    #  seed.files
    #end

    def all
      seed.files
    end

    # TODO: output settings ?
    def work_settings
      @work_settings ||= (
        file = work_path.glob('.config/sow/metadata.{yml,yaml}').first
        data = file ? YAML.load(File.new(file)) : {}
        data
      )
    end

    # TODO: Use XDG for .config
    # TODO: Run thru ERB
    def user_settings
      @user_settings ||= (
        file = Dir[File.expand_path('~/.config/sow/metadata.{yml,yaml}')].first
        data = file ? YAML.load(File.new(file)) : {}
        data
      )
    end

    # TODO: do we really need these?
    #def seed_settings
    #  @seed_settings ||= (
    #    file = stage_path.glob('_metadata.{yml,yaml}').first
    #    data = file ? YAML.load(File.new(file)) : {}
    #    data
    #  )
    #end

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
        if File.exist?(seed.directory + file)
          fileutils.cp(seed.directory + file, file)
        end
      end
      # append text to file
      File.open(file, 'a'){ |f| f << text.to_s }
    end

    # Copy seed file(s). Except for specially recognized files (.png, .jpg, etc.)
    # all files will be run thru the template renderer and rendered according to
    # the extension of the file. The extension `.verbatim` can be used to prevent
    # this and instead copy the file verbatim. Or a specific render format can
    # be specified via +:render+, which will be used instead.
    #
    # == OPTIONS
    #
    # `:from => <dir>`
    # Directory of templates relative to +seed.directory+.
    #
    # `:files => <glob>`
    # Glob pattern of file names relative to +from+.
    #
    # `:to => <dir>` 
    # Destination directory relative to +output+.
    #
    # `:render => <format>`
    # Format to render file as before saving. Defaults to file extname,
    # if recognized. Otherwise verbatim.
    #
    def copy(options)
      from  = options.delete(:from)
      to    = options.delete(:to)
      files = options.delete(:files) || '**/*'

      tmpl = seed.directory

      list = []

      if from
        (tmpl + from).glob_relative(files).each do |f|
          list << [File.join(from, f), f.to_s]
        end
      else
        tmpl.glob_relative(files).each do |f|
          list << [f.to_s, f.to_s]
        end
      end

      if to
        list.map!{ |src, dest| [src, File.join(to,dest)] }
      end

      list.each do |src, dest|
        template(src, dest, options)
      end
    end

=begin
    # Copy a template file or a glob of template files. Except for specially
    # recognized files (.png, .jpg, etc.) all files will be run thru ERB.
    # The extension `.verbatim` can be used to prevent this and instead copied
    # verbatim --e.g. `foo.erb.verbatim` will result in `foo.erb`.
    def cp(from, to=nil, opts={})
      opts, to = to, nil if Hash===to

      tmpl = seed.directory

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
        template(from, fname, opts)
      end
    end
=end

    # Copy template file to +dest+ with +mode+.
    # Or create template directory as +dest+ with +mode+.
    def template(src, dest, opts={})
      mode = opts[:mode]
      from = seed.directory + src
      dest = fill_in_the_blanks(dest)
      if from.directory?
        mkdir(dest)
      else
        if verbatim?(dest, opts)
          dest   = dest.chomp('.verbatim')
          iopts  = mode ? {:mode=>mode} : {}
          parent = File.dirname(dest)
          mkdir(parent)
          fileutils.install(from, dest, iopts)
        else
          ext = (opts[:render] || File.extname(from)).to_s
          if Malt.support?(ext)
            result = render(from, ext)
            dest   = dest.chomp(File.extname(from)) # TODO: what about rhtml -> html, etc ?
          else
            result = File.read(from)
          end
          parent = File.dirname(dest)
          mkdir(parent)
          File.open(dest, 'w'){|f| f << result.to_s}
          fileutils.chmod(mode, dest) if mode
        end
      end
    end

    #--
    # TODO: Do we need a new context every time?
    #++
    def render(file, ext)
      #context = Context.new(self, metadata)
      #ERB.new(text).result(context.to_binding)
      data = metadata.data
      Malt.render(:file=>file, :data=>data, :type=>ext)  #TODO: rename `type`
    end

    #
    #def altext(ext)
    #  Malt.rendered_extension(ext)
    #end

    #
    #def render_string(text, format)
    #  return text unless Malt.support?(format)
    #  context = Context.new(self, metadata)  # TODO: Do we need a new context every time?
    #  #ERB.new(text).result(context.to_binding)
    #  Malt.render(:text=>text, :format=>format)
    #end

    #
    VERBATIM_EXTENSIONS = %w{.jpg .png .gif .pdf .ogv .ogg}

    # Should a given file be processed as a template (via ERB).
    def verbatim?(file, opts={})
      return true if opts[:verbatim]
      return true if opts[:render].to_s == 'verbatim'
      case File.extname(file)
      when '.verbatim'
        true
      when *VERBATIM_EXTENSIONS
        true
      else
        false
      end
    end

    # FIXME: Import another seed. Be specific about the seed name when using this.
    def import(name)
      Seed.new(name).sow!(@options)
    end

    # File names can have __name__ style variables to
    # be filed in by metadata. This method handles the
    # substituion.
    def fill_in_the_blanks(string)
      string.gsub(/___(.*?)___/) do |match|
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
    #def to_binding
    #  binding
    #end

    # Encapsulate a set of copy transactions. This is better than using
    # copy directly b/c it allows multiple copy commands to be resolved
    # into a single copy operation, which can prevent duplicate copying.
    # The last copy command takes precedence over the first.
    class Scaffold
      #
      attr :sower

      #
      attr :copylist

      #
      def initialize(sower, &block)
        @sower       = sower
        @copy_list   = {}
        @append_list = {}
        instance_eval(&block)
      end

      #
      def copy(options={})
        from  = options.delete(:from)
        to    = options.delete(:to)
        files = options.delete(:files) || '**/*'

        tmpl = sower.seed.directory

        list = []

        if from
          (tmpl + from).glob_relative(files).each do |f|
            list << [File.join(from, f), f.to_s]
          end
        else
          tmpl.glob_relative(files).each do |f|
            list << [f.to_s, f.to_s]
          end
        end

        if to
          list.map!{ |src, dest| [src, File.join(to,dest)] }
        end

        list.each do |src, dest|
          @copy_list[dest] = [src, options]
        end
      end

      #
      def append(file, text)
        @append_list << [file, text]
      end

      # Copies occur before appends.
      def commit!
        @copy_list.each do |dest, (src, opts)|
          sower.template(src, dest, opts)
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
      def initialize(sower)
        @sower = sower
        @data  = settings.inject({}){ |h, s| h.merge!(s); h }
      end

      #
      def data
        @data
      end

      #
      def settings
        @settings ||= [
          ENV,
          #@sower.seed_setting,
          @sower.user_settings,
          @sower.work_settings,
          @sower.settings
        ]
      end

      # TODO: Need to make sources more easily adjustable for use with POM extension.
      #def metadata_sources
      #  @metadata_sources ||= [
      #    @data,
      #    @sower.settings,
      #    @sower.work_settings,
      #    @sower.user_settings,
      #    #@sower.seed_settings,
      #    ENV
      #  ]
      #end

      # Get metadata entry.
      def [](name)
        @data[name.to_s]
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
          self[name] = args.first
        when /\?$/
          self[sym.chomp('?')]
        when /\!$/
          # TODO: if method_missing ends in '!'
        else
          self[sym]
        end
      end
    end

=begin
    # Templates are all rendered within the scope of a context object.
    # This limits access to information pertinent. All metadata
    # can be accessed by name, as this this object delegate missing methods to a Metadata instance.
    #
    class Context
      instance_methods.each{ |m| undef_method(m) unless m.to_s =~ /^(__|respond_to\?$)/ }

      #
      def initialize(sower, metadata)
        @sower    = sower
        @metadata = metadata.data
      end

      #
      #def method_missing(s, *a, &b)
      #  @metadata[s.to_s] || "___#{s}___"  # "__'#{s}'__"
      #end

      #
      def to_binding
        binding
      end

      #
      def render(file, options={})
        options[:file] = file
        options[:data] = @metadata #binding
        Malt.render(options)
      end

      #
      #def working_directory
      #  @metadata.seed.working_directory
      #end

      def inspect
        "#<Sow::Sower::Context>"
      end
    end
=end

  end

end

