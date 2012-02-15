module Quarry

  class Template

    # Evaluation context for an template's copy procedure.
    #
    class Script

      #
      #
      #
      def self.run(template, arguments, settings, options)
        new(template, options).call(arguments, settings)
      end

      #
      # Initialize CopyScript.
      #
      # @param [Template] template
      #   Template the copy script is going to processes.
      #
      def initialize(template, options)
        @template = template
        @options  = options

        @output   = Pathname.new(options[:output] || Dir.pwd)
        #@work    = Pathname.new(Dir.pwd)
        @stage    = options[:stage]

        reset
      end

      #
      # Empty the actions lists.
      #
      def reset
        @mkdir_list  = []
        @copy_list   = {}
        @append_list = []
      end

      #
      # Use interactive mode? This means that the use will be prompted
      # for missing metadata.
      #
      def interactive?
        @options[:interactive]
      end

      #
      # Parse copy file.
      #
      # @param [Array] arguments
      #   Templates can accept an Array of *arguments* which can refine their 
      #   behvior.
      #
      # @param [Hash] settings
      #   Template can accept a Hash of `key=>value` *settings* which refine
      #   their behavior.
      #
      def call(arguments, settings)
        @arguments = arguments
        @call_settings  = settings

        Dir.chdir(stage_directory) do
          scaffold do
            instance_eval(template.script, template.config_file)  # TODO: line_number in config_file
          end
        end
      end

      #
      #
      #
      def scaffold(&block)
        instance_eval(&block)
        Commit.new(self).commit!
        reset
      end

      #
      #
      #
      def template
        @template
      end

      #
      # Destination directory.
      #
      def output
        @output
      end

      # Basename of output destination directory.
      #def destname
      #  @destname ||= (
      #    File.basename((template.options.output || Dir.pwd).chomp('/'))
      #  )
      #end

      #
      # Temporary staging directory.
      #
      def stage_directory
        @stage ||= (
          name = File.basename(output).chomp('/')
          time = Time.now.to_i
          Dir.tmpdir + "/quarry/stage/#{name}/#{time}"
        )
      end

      #
      # Name of the template.
      #
      def name
        template.name
      end

      #
      #def selection
      #  @selection
      #end

      #
      # Ordered arguments, from the command line.
      #
      def arguments
        @arguments
      end

      #
      # Current working directory.
      #
      # @todo Should this be the same as the #output directory?
      #
      def work
        @output #@work
      end

      #
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

      #
      # Does the output directory contain any files?
      #
      def empty?
        output.children.empty?
      end

      #
      # Metadata access.
      #
      def metadata
        @metadata ||= Metadata.new(self)
      end

      #
      # Convenient alias for `#metadata`.
      #
      alias_method :data, :metadata

      #
      # Gen metadata entry.
      #
      def get(key)
        data[key]
      end

      #
      # Set metadata entry.
      #
      def set(key, value)
        data[key] = value
      end

      #
      # Set metadata entry if not already set.
      #
      def let(key, value)
        data[key] ||= value
      end

      #def template_files
      #  template.files
      #end

      def all
        #template.files
        "**/*"
      end

      #
      #
      #
      def resources
        [template_settings, work_settings, user_settings]
      end

      #
      # Merged settings from template_settings, work_settings and user_settings,
      # in that order of precedence.
      #
      #--
      # TODO: Should we include ENV at the end of settings?
      #++
      def settings
        @settings ||= (
          sets = [user_settings, work_settings, template_settings]
          sets.inject({}){ |h,s| h.merge!(s); h }
        )
      end

      #
      # Invocation settings are passed in via #initialize along with the template.
      # These settings typically come from the command line.
      #
      def template_settings
        @call_settings
      end

      #
      # Work settings are found in the output directory (which is usually the
      # current working directory) in a `.quarry/settings.yml` file.
      #
      def work_settings
        @work_settings ||= (
          file = output.glob(DEST_METADATA).first
          data = file ? YAML.load(File.new(file)) : {}
          data
        )
      end

      #
      # User settings are found in a users home directory in the
      # `.quarry/settings.yml` or `.config/quarry/settings.yml` file.
      #
      def user_settings
        @user_settings ||= (
          file = Dir[File.expand_path(HOME_METADATA)].first
          text = File.read(file)
          yaml = ERB.new(text).result(binding)  # TODO: what binding ?
          #yaml = Malt.render(:file=>file, :type=>:erb, :data=>binding)
          data = file ? YAML.load(yaml) : {}
          data
        )
      end

      #
      # TODO: Make extensions plugable?
      #
      def utilize(libname)
        require "quarry/extensions/#{libname}"
      end

      #
      # Evaluate external script in copy file context.
      #
      # TODO: should his be relative to CTRL directory?
      #
      def import(relpath)
        file = File.join(template.path, relpath)
        instance_eval(File.read(file), file)
      end

      # .--- TRANSACTION METHODS ---.

      #
      # Make a directory.
      #
      def mkdir(dir)
        @mkdir_list << [:mkdir, dir]
      end

      #
      # Verbatim copy (unless :render option is used).
      #
      def copy(*arguments)
        if not Hash === arguments.last
          arguments << {}
        end
        options = arguments.last
        options[:verbatim] = true unless options[:render]
        render(*arguments)
      end

      # Encapsulate a set of copy transactions. This is better than using
      # copy directly b/c it allows multiple copy commands to be resolved
      # into a single copy operation, which can prevent duplicate copying.
      # The last copy command takes precedence over the first.

      #
      def render(*args)
        options = Hash===args.last ? args.pop : {}
        files, to, _ = *args

        raise ArgumentError if files && options[:files]
        raise ArgumentError if to    && options[:to]

        files   = files || options.delete(:files) || '**/*'
        to      = to    || options.delete(:to)
        from    = options.delete(:from)

        dir = template.path
        dir = from ? dir + from : dir

        list = []

        [files].flatten.each do |fmatch|
          dir.glob_relative(fmatch).each do |f|
            next if control_file?(f)
            list << [(from ? File.join(from, f) : f.to_s), f.to_s]
            #list << [f.to_s, f.to_s]
          end
        end

        #if from
        #  (dir + from).glob_relative(files).each do |f|
        #    next if f.basename.to_s == "Sowfile"
        #    next if f.basename.to_s == "_Sowfile"
        #    list << [File.join(from, f), f.to_s]
        #  end
        #else
        #  dir.glob_relative(files).each do |f|
        #    next if f.basename.to_s == "Sowfile"
        #    next if f.basename.to_s == "_Sowfile"
        #    list << [f.to_s, f.to_s]
        #  end
        #end

        if to
          list.map!{ |src, dest| [src, File.join(to,dest)] }
        end

        list.each do |src, dest|
          @copy_list[dest] = [src, options]
        end
      end

      #
      # Append text to a file.
      #
      def append(file, text)
        @append_list << [file, text]
      end
     
      #
      # Collect transations for processing.
      #
      def transactions
        list = []
        @mkdir_list.each do |dir, opts|
          list << [:mkdir, dir, opts]
        end
        @copy_list.each do |dest, (src, opts)|
          list << [:copy, src, dest, opts]
        end
        @append_list.each do |(file, text)|
          list << [:append, file, text]
        end
        list
      end


      # Plant another template.
      #--
      # TODO: This indicates that this whole class needs some refactoring.
      #++
      #def plant(template_name)
      #  #template = Template.new(name, template.arguments, template.settings)
      #  #Templater.new(template, @options).quarry!(@stage)
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

      # TODO: Is using global $FORCE variable okay?

      #
      # Abort if destination is not empty, less ignored files.
      # This method acts as a precaution for templates that are 
      # intended to be used to create new projects.
      #
      # The user can override this check with the --force option.
      #
      def ensure_empty(*ignore)
        files = Dir.entries(Dir.pwd) - (['.', '..'] + ignore)
        if !files.empty? and !$FORCE
          raise "This template is intended for new projects.\n" +
                "But the destination directory is not empty.\n" +
                "Please use --force option to proceed."
        end
      end

      #
      #
      #
      def control_file?(file)
        CONFIG_FILE == File.basename(file.to_s)
      end

    end

  end

end

