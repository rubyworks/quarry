module Quarry

  class Template

    # Evaluation context for an template's copy procedure.
    #
    class Script

      GLOB = TEMPLATE_DIRECTORY + "/copy.rb"

      #
      # Initialize CopyScript.
      #
      # @param [Template] template
      #   Template the copy script is going to processes.
      #
      def initialize(template)
        @template = template
        @file     = Dir.glob(template.path + GLOB).first

        if @file
          @script = File.read(@file.to_s)
        else
          @script = 'copy all'
        end

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
      #
      #
      def to_s
        @script
      end

      #
      # Use interactive mode? This means that the use will be prompted
      # for missing metadata.
      #
      def interactive?
        @interact
      end

      # TODO: Maybe there should ba a Script::Runner class instead ?

      # Setup generation options for executing the script.
      #
      # @param [Hash] config
      #   Configuration options for generation.
      #
      # @return [self]
      #
      def setup(options)
        @output   = Pathname.new(options[:output] || Dir.pwd)
        @stage    = options[:stage]
        @interact = options[:interactive]

        reset

        self
      end

      #
      # Evaluate copy script.
      #
      # @param [Array] arguments
      #   Templates can accept an Array of *arguments* which can refine their 
      #   behvior.
      #
      # @param [Hash] settings
      #   Template can accept a Hash of `key=>value` *settings* which refine
      #   their behavior.
      #
      def call(arguments, settings={})
        @arguments = arguments
        @call_settings  = settings

        # arguments can be specified in config.yml
        template.script_arguments.each do |name, opts|
          argument name, opts
        end

        Dir.chdir(stage_directory) do
          scaffold do
            instance_eval(to_s, template.config.file)
          end
        end
      end

      #
      #
      #
      def scaffold(&block)
        instance_eval(&block)
        Commit.new(self).commit!
        reset  # TODO: commit should hand reset ?
      end

      #
      # Template instance.
      #
      # @return [Template]
      #
      def template
        @template
      end

      #
      # Destination directory is where template files will ultimately be
      # copied.
      #
      def output
        @output
      end

      alias_method :work, :output

      #
      # Temporary staging directory is the current working directory while
      # the copy script is being evaluated.
      #
      # @return [Pathname]
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
      # Template configurtion data.
      #
      def config
        template.config
      end

      #
      # Ordered arguments, from the command line.
      #
      def arguments
        @arguments
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
        value = arguments.shift || options[:default] || metadata[name]
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
      def set(key, value=nil, &block)
        data[key] = (
          if block_given?
            block.call
          else
            value
          end
        )
      end

      #
      # Set metadata entry if not already set.
      #
      def let(key, value=nil, &block)
        data[key] ||= (
          if block_given?
            block.call
          else
            value
          end
        )
      end

      #def template_files
      #  template.files
      #end

      def all
        #template.files
        "**/*"
      end

      #
      # List of settings from call_settings, work_settings, conf_settings and
      # user_settings, in that order of precedence.
      #
      # @todo Should `conf_settings` come before `work_settings` ?
      #
      # @return [Array] List of settings.
      #
      def settings
        [call_settings, work_settings, conf_settings, user_settings]
      end

      #
      # Invocation settings are passed in via #initialize along with the template.
      # These settings normally come from the command line and take precedence
      # over other settings.
      #
      def call_settings
        @call_settings
      end

      #
      # Work settings are found in the project directory (which is usually the
      # current working directory) in the `WORK` configuration directory.
      # Common settings are stored in `settings.yml` and per-template settings
      # are stored in a file named after the template, e.g. `name.yml`.
      #
      def work_settings
        @work_settings ||= (
          data = {}

          file = output.glob(File.join(WORK,'settings.{yml,yaml}')).first
          data.update( YAML.load_file(file) ) if file

          file = output.glob(File.join(WORK,template.name+'.{yml,yaml}')).first
          data.update( YAML.load_file(file) ) if file

          data
        )
      end

      #
      # User settings are found in a users home directory in the
      # `.quarry/settings.yml` or possibly `.config/quarry/settings.yml`.
      #
      def user_settings
        @user_settings ||= (
          data = {}

          file = Dir[HOME_METADATA].first
          if file
            text = File.read(file)
            yaml = ERB.new(text).result(binding) #metadata.to_binding)  # TODO: correct binding ?
            data.update( YAML.load(yaml) )
          end

          data
        )
      end

      #
      # Configuration settings are resources designated by the template to
      # be looked for in the project.
      #
      def conf_settings
        data = {}

        [config.resource].flatten.map do |file|
          path = File.join(output, file)
          if File.exist?(path)
            #begin
              case File.extname(path)
              when '.yml', '.yaml'
                path_data = YAML.load_file(path)
              when '.json'
                path_data = JSON.load_file(path)  # FIXME
              else
                path_data = YAML.load_file(path)
              end
            #rescue => err
            #  warn err.to_s
            #end
            data = path_data.merge(data)
          end
        end

        data
      end

      #
      # Load script extension.
      #
      # @todo Use regular reuquire if not found?
      # @todo Make these pluggable?
      #
      def utilize(libname)
        if RUBY_VERSION < '1.9'
          require "quarry/template/script/extensions/#{libname}"
        else
          require "script/extensions/#{libname}"
        end
      end

      #
      # Evaluate external script in copy file context.
      #
      def import(relpath)
        file = File.join(template.path, TEMPLATE_DIRECTORY, relpath)
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
        file.to_s.start_with?(TEMPLATE_DIRECTORY)
      end

    end

  end

end

