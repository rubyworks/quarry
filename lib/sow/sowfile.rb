require 'erb'
require 'malt'
require 'fileutils'
require 'tmpdir'

require 'sow/sowfile/context'
require 'sow/sowfile/metadata'
require 'sow/sowfile/transaction'

module Sow

  # Evaluation context for a seed's Sowfile, which "sows" the seed's
  # files to a staging ground.
  #
  class Sowfile

    # Location of Sow user configuration. Uses XDG directrory standard!!!
    HOME_CONFIG = ENV['XDG_CONFIG_HOME'] || '~/.config'

    # File pattern for looking up user matadata.
    HOME_METADATA = File.join(HOME_CONFIG,'sow/metadata.{yml,yaml}')

    # File pattern for looking up desination matadata.
    DEST_METADATA = '{.sow,.config,config}/sow/metadata.{yml,yaml}'

    #
    def self.run(seed, arguments, settings, options)
      new(seed, options).call(arguments, settings)
    end

    # New Sowfile.
    #
    # ## ARGUMENTS
    #
    #   * `seed`
    #     Seed to which the Sowfile belongs.
    #
    def initialize(seed, options)
      @seed    = seed
      @name    = seed.name
      @options = options

      @output  = Pathname.new(options[:output] || Dir.pwd)
      #@work    = Pathname.new(Dir.pwd)
      @stage   = options[:stage]
    end

    # ## ARGUMENTS
    #
    #   * `selection`
    #     Specific aspect of seed to germinate.
    #
    #   * `arguments`:
    #     Seeds can accept an Array of *arguments* which can refine their 
    #     behvior.
    #
    #   * `settings`:
    #     Seed can accept a Hash of `key=>value` *settings* which refine
    #     their behavior.
    #
    def call(arguments, settings)
      @arguments = arguments
      @call_settings  = settings

      Dir.chdir(stage_directory) do
        instance_eval(seed.script, seed.sowfile)
      end
    end

    #
    def seed
      @seed
    end

    # Output directory.
    def output
      @output
    end

    # Basename of output destination directory.
    #def destname
    #  @destname ||= (
    #    File.basename((seed.options.output || Dir.pwd).chomp('/'))
    #  )
    #end

    # Temporary staging directory.
    def stage_directory
      @stage ||= (
        name = File.basename(output).chomp('/')
        time = Time.now.to_i
        Dir.tmpdir + "/sow/stage/#{name}/#{time}"
      )
    end

    # The seed name.
    def name
      @name
    end

    # Name of the seed.
    def name
      seed.name
    end

    #
    #def selection
    #  @selection
    #end

    # Arguments (from commandline).
    def arguments
      @arguments
    end

    # Current working directory.
    #--
    # TODO: Should this be the same as the output directory?
    #++
    def work
      @output #@work
    end

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

    #
    alias_method :data, :metadata

    #
    def get(key)
      data[key]
    end

    #
    def set(key, value)
      data[key] = value
    end

    #
    def let(key, value)
      data[key] ||= value
    end

    #def template_files
    #  seed.files
    #end

    #def all
    #  seed.files
    #end

    #
    def resources
      [seed_settings, work_settings, user_settings]
    end

    # Merged settings from seed_settings, work_settings and user_settings,
    # in that order of precedence.
    #--
    # TODO: Should we include ENV at the end of settings?
    #++
    def settings
      @settings ||= (
        sets = [user_settings, work_settings, seed_settings]
        sets.inject({}){ |h,s| h.merge!(s); h }
      )
    end

    # Invocation settings are passed in via #initialize along with the seed.
    # These settings typically come from the commandline.
    def seed_settings
      @call_settings
    end

    # Work settings are found in the output directory (which is usually the
    # current working directory) in a `.sow/settings.yaml` file.
    def work_settings
      @work_settings ||= (
        file = output.glob(DEST_METADATA).first
        data = file ? YAML.load(File.new(file)) : {}
        data
      )
    end

    # User settings are found in a users home directory in a
    # `.config/sow/settings.yaml` file.
    def user_settings
      @user_settings ||= (
        file = Dir[File.expand_path(HOME_METADATA)].first
        #text = File.read(file)
        yaml = Malt.render(:file=>file, :type=>:erb, :data=>binding)
        data = file ? YAML.load(yaml) : {}
        data
      )
    end

    # TODO: Make extensions plugable?
    def utilize(libname)
      require "sow/extensions/#{libname}"
    end

    #
    def import(relpath)
      file = File.join(seed.path, relpath)
      instance_eval(File.read(file), file)
    end

    # Plant another seed.
    #--
    # TODO: This indicates that this whole class needs some refactoring.
    #++
    #def plant(seed_name)
    #  #seed = Seed.new(name, seed.arguments, seed.settings)
    #  #Sower.new(seed, @options).sow!(@stage)
    #end

    #
    #def setup(&block)
    #  @setup = block if block
    #  @setup
    #end

    #
    #def select(name, &block)
    #  if selection == name.to_s
    #    setup.call if setup
    #    block.call
    #  end
    #end

    # Make directory. This will auto-create subdirecties,
    # equivalent to `mkdir -p`.
    def mkdir(dir)
      fileutils.mkdir_p(dir) unless File.directory?(dir)
    end

    # Append +text+ to the end of a +file+.
    def append(file, text)
      if File.exist?(file)
        File.open(file, 'a'){ |f| f << text.to_s }
      else # c.o.w. procedure
        src = output + file
        if src.exist?
          mkdir(File.dirname(file))
          fileutils.cp(src, file)
          File.open(file, 'a'){ |f| f << text.to_s }
        end
      end
    end

    # Copy seed file(s). Except for specially recognized files (.png, .jpg, etc.)
    # all files will be run thru the template renderer and rendered according to
    # the extension of the file. The extension `.verbatim` can be used to prevent
    # this and instead copy the file verbatim. Or a specific render format can
    # be specified via +:render+, which will be used instead.
    #
    # == ARGUMENTS
    #
    # `files`:
    # Glob pattern or an array of patterns of file names relative to +from+.
    #
    # `to`:
    # Destination directory relative to +output+.
    #
    # == OPTIONS
    #
    # `from => <dir>`:
    # Directory of templates relative to +seed.directory+.
    #
    # `:files => <glob>`:
    # Glob pattern or an array of patterns of file names relative to +from+.
    #
    # `:to => <dir>`:
    # Destination directory relative to +output+.
    #
    # `:render => <format>`:
    # Format to render file as before saving. Defaults to file's extension name,
    # if recognized. Otherwise `verbatim`.
    #
    def copy(*args)
      options = Hash===args.last ? args.pop : {}
      files, to, _ = *args

      raise ArgumentError if files && options[:files]
      raise ArgumentError if to    && options[:to]

      files   = files || options.delete(:files) || '**/*'
      to      = to    || options.delete(:to)
      from    = options.delete(:from)

      dir = seed.directory
      dir = from ? dir + from : dir

      list = []

      [files].flatten.each do |fmatch|
        dir.glob_relative(fmatch).each do |f|
          next if f.basename.to_s == "Sowfile"
          next if f.basename.to_s == "_Sowfile"
          list << [(from ? File.join(from, f) : f.to_s), f.to_s]
          #list << [f.to_s, f.to_s]
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
      data = Context.new(self)
      #ERB.new(text).result(context.to_binding)
      #data = metadata.data
      ext  = ext.to_s.sub(/^\./, '')  # FIXME Malt should handle this
      Malt.render(:file=>file.to_s, :data=>data, :type=>ext)
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
    def transaction(&block)
      Transaction.new(self, &block).commit!
    end

    #
    def fileutils
      $DEBUG ? FileUtils::Verbose : FileUtils
    end

  end

end
