require 'sow/core_ext'
require 'sow/session'
require 'sow/logger'
require 'sow/script'
require 'sow/generators/create'
require 'sow/generators/update'
require 'sow/generators/delete'

require 'facets/erb'
require 'facets/ostruct'
require 'facets/kernel/instance_class'

module Sow

  # Plugin encapsulates information about a sow plugin.
  #
  class Plugin
    # Name of template directory.
    TEMPLATE_NAME = 'template/'
    # Name of plugin script file.
    SCRIPT_NAME = 'SCRIPT{,.rb}'
    # Name of usage document.
    USAGE_NAME = 'USAGE{,.txt}'
    # Name of metadata file.
    DATA_NAME = 'DATA{,.yml,.yaml}'
    # Name of copy file.
    COPY_NAME = 'COPY{,.yml,.yaml}'

    # Instanance of Session.
    attr :session
    # Location of plugin.
    attr :location
    # Argmuent
    attr :argument
    # Options
    attr :options
    # Desitnation pathname
    attr :destination

    #
    def initialize(session, location, options)
      @session  = session
      @options  = options.to_ostruct

      @location = Pathname.new(location)

      @copy = []
    end

    # Metadata from scaffold destination.
    def metadata
      session.metadata
    end

    # Destination for scaffolding.
    def destination
      session.destination
    end

    # Argument for main command option.
    def argument
      options.argument
    end

    # Directory with template files.
    def template_dir
      @template_dir ||= grab(TEMPLATE_NAME).chomp('/')
    end

    # File containing usage text.
    def usage_file
      @usage_file ||= grab(USAGE_NAME)
    end

    # Metadata file.
    def meta_file
      @meta_file ||= grab(DATA_NAME)
    end

    # Transfer file.
    def seed_file
      @seed_file ||= grab(COPY_NAME)
    end

    # Traditional alternative to the meta & seed file.
    def script_file
      @script_file ||= grab(SCRIPT_NAME)
    end

    # Usage text.
    def usage
      @usage ||= (
        if usage_file
          Usage.new(usage_file)
        else
          "Generate #{self.class.name} scaffolding."
        end
      )
    end

    # Plugin's special metadata. These entries are
    # converted to methods for rendering of the 
    # transfer list.
    def meta
      @meta ||= (
        if meta_file
          YAML.load(File.new(meta_file))
        else
          {}
        end
      )
    end

    # Plugin's transfer list.
    def seed
      @seed ||= (
        if seed_file
          res = template.erb_result(File.read(seed_file))
          YAML.load(res)
        else
          [{'from' => '**/*'}]
        end
      )
    end

  private

    # Grab the first instance of a mathcing glob as a Pathname object.
    def grab(glob)
      file = Dir.glob(File.join(location, glob), File::FNM_CASEFOLD).first
      file ? Pathname.new(file) : nil
    end

    # Erb OpenTemplate
    def template
      @template ||= (
        ERB::OpenTemplate.new(options, session, :options => options, :metadata=>metadata)
      )
    end

=begin
    # Setup up the option parsing for the specific plugin.
    # This method takes an instance of OptionParser.
    def setup_options(parser)
      txt = []
      txt << "Usage: sow " + script[:usage] if script[:usage]
      txt << script[:help] if script[:help]
      parser.banner = txt.join("\n")
      script[:options].each do |name, desc, valid|
        if valid.arity == 0
          parser.on("--#{name}", desc, &valid)
        else
          parser.on("--#{name} [VALUE]", desc, &valid)
        end
      end
    end
=end

  public

    # Prepare for scaffolding procedure. If a script.rb file
    # was provided then uses the class defined within it
    # to build the proper copylist.
    #
    # IMPORTANT: The class name must have the same as the
    # plugin directory it is within.
    #
    # If not using a script.rb, but rather a seed.yml and/or
    # a meta.yml file, this reads and prepares those instead.

    def setup
      if script_file
        require(File.expand_path(script_file))
        scriptClass = Script.registry[location.basename.to_s]
        @script = scriptClass.new(session, options)
        @script.setup
        @script.manifest
        @copy = @script.copylist
      else
        prepare_meta
        prepare_seed
        prepare_data
      end
    end

      #setup_arguments #(arguments)
      #setup_metadata
      #setup_script #(session)
      #init
      #parse

    # Any arguments defined in the script get there assigments
    # defined as singleton methods via the script[]= call.
    #def setup_arguments #(a)
    #  #h = {}
    #  a = script[:values]
    #  script[:arguments].each_with_index do |(name, desc, valid), i|
    #    if valid
    #      script[name] = valid.call(a[i])
    #    else
    #      script[name] = a[i]
    #    end
    #  end
    #  #@args = h #TODO: where?
    #end

    # Collect any metadata settings that may have been made
    # in the initial script evaluation.
    #def setup_metadata
    #  script.metadata.each do |k,v|
    #    metadata[k] = v
    #  end
    #end

    # Setup the plugin with information about current operation.
    #
    # TODO: This seems wrong. Need to figure a better way!
    #
    #def setup_script
    #  script.instance_variable_set("@session", session)
    #  script.instance_variable_set("@metadata", metadata)
    #  #script[:values].each do |v|
    #  #end
    #end

    # Define metadata entries as singleton methods of the  Erb template.
    def prepare_meta
      meta.each do |m,c|
        template.instance_class do
          eval %{
            def #{m}
              #{c}
            end
          }
        end
      end
      # validate
      template.validate if meta['validate']
    end

    #
    def prepare_seed
      seed.each do |opts|
        opts.rekey!(&:to_s)
        from = opts.delete('from')
        to   = opts.delete('to') || '.'
        cond = opts.delete('if')
        next unless template.instance_eval(cond) if cond
        @copy << [from, to, opts]
      end
    end

    #
    def prepare_data
      meta.each do |m,c|
        metadata[m] = template.__send__(m)
      end
    end

    # Designate a copying action.
    #
    #def copy(*from_to_opts)
    #  opts = Hash===from_to_opts.last ? from_to_opts.pop : {}
    #  from, to = *from_to_opts
    #  to = to || '.'
    #  @copylist << [from, to, opts]
    #end

    # Expanded copy list.
    def copylist
      @copylist ||= copylist_sort(copylist_glob(@copy)) #redest(list)
    end

    # Raw copylist as defined in the script.
    #def script_copylist
    #  @script_copylist ||= (
    #    script[:copytemp].each{|s| s.call}
    #    script[:copylist]
    #  )
    #end

    # Does the script define a package name.
    #def name
    #  script[:name]
    #end

    # Expand copylist by globbing entries.

    def copylist_glob(copylist)
      list = []
      dotpaths = ['.', '..']

      copylist.each do |from, into, opts|
        cdir = opts['cd'] || '.'
        srcs = []

        Dir.chdir(template_dir + cdir) do
          less = opts['less'] ? Dir.multiglob_r(opts['less']) : []
          srcs = Dir.glob(from, File::FNM_DOTMATCH)
          srcs = srcs - less
          srcs = srcs.reject{ |d| File.basename(d) =~ /^[.]{1,2}$/ }
        end

        # remove +less+ option, not needed any more
        opts.delete('less')
        #srcs = filter_paths(srcs)
        srcs.each do |src|
          case into
          when /\/$/
            dest = File.join(into, File.basename(src))
          when '.'
            dest = src
          else
            dest = into
          end
          source = (cdir == '.' ? src : File.join(cdir, src))
          list << [template_dir, source, template_to_filename(dest), opts] #dest
        end
      end
      list = uniq(list)
      list
    end

    # Reduce copylist to uniq transfers. If transfers are the same
    # the later transfere takes precedence. Transfire options are
    # not considered in determining uniquness.

    def uniq(list)
      h = {}
      list.each do |dir, src, dest, opts|
        h[[dir,src,dest]] = opts
      end
      h.inject([]){ |a,x| a << x.flatten; a }
    end

=begin
    # Filter out special paths from copylist.
    #
    def filter_paths(paths)
      filter.each do |re|
        paths = paths.reject do |pn|
          case re
          when Regexp
            re =~ pn.to_s
          else
            re == pn.to_s
          end
        end
      end
      paths
    end
=end

    # Convert a template pathname into a destination pathname.
    # This allows for substitution in the pathnames themselves
    # by using '__name__' notation.
    #
    def template_to_filename(path)
      name = path.dup #chomp('.erb')
      name = name.gsub(/__(.*?)__/) do |md|
        metadata.__get__($1) || 'FIXME'  # TODO: raise error?
      end
      #if md =~ /^(.*?)[-]$/
      #  name = metadata[md[1]] || plugin.metadata(md[1]) || name
      #end
      name
    end

    # Sort the list, directory before files and in alphabetical order.
    def copylist_sort(list)
      dirs, files = *copylist_partition(list)
      dirs.sort{|a,b| a[2]<=>b[2]} + files.sort{|a,b| a[2]<=>b[2]}
    end

    # Partition the list between directories and files.
    def copylist_partition(list)
      list.partition{ |loc, src, dest, opts| (loc + src).directory? }
    end

    # Complete destination.
    #def copylist_dest(list)
    #  list.collect do |src, dest|
    #    case dest
    #    when nil
    #      dest = src
    #    when '/.'
    #      dest = src
    #    when /\/[.]$/
    #      dest = File.join(dest.chomp('/.'), src)
    #    when '/', '.'
    #      dest = File.basename(src)
    #    when /\/$/
    #      #dest = File.join(dest, template_to_filename(File.basename(src)))
    #      dest = File.join(dest, File.basename(src))
    #    #else
    #    #  dest = dest
    #    end
    #    dest = template_to_filename(dest)
    #    [src, dest]
    #  end
    #end

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

end#module Sow





=begin
    #
    def create(arguments, options={})
      setup_for(:create, arguments, options)

      #setup_arguments #(arguments)
      #session.mode = :create

      # collect metadata settings
      #plugin.script.metadata.each do |k,v|
      #  metadata[k] = v
      #end

      # this is kind of odd here
      #plugin.script_setup(session)

      #session   = Session.new(arguments, options)
      generator = Generators::Create.new(session, location, copylist)
      generator.generate
    end

    #
    def update(arguments, options={})
      setup_for(:update, arguments, options)
      #setup_arguments #(arguments)
      #session.mode = :update

      #session   = Session.new(arguments, options)
      generator = Generators::Update.new(session, location, copylist)
      generator.generate
    end

    #
    def delete(arguments, options={})
      setup_for(:delete, arguments, options)
      #setup_arguments #(arguments)
      #session.mode = :delete
      #session   = Session.new(arguments, options)
      generator = Generators::Delete.new(session, location, copylist)
      generator.generate
    end

    # No specific operation mode given, select one
    # based on plugin and state of current location.
    def select(arguments, options={})
      #setup_arguments #(arguments) # FIXME
      #session = Session.new(arguments, options)
      if name && session.sowed?  #FIXME name?
        setup_for(:update, arguments, options)
        generator = Generators::Update.new(session, location, copylist)
        generator.generate
      else
        setup_for(:create, arguments, options)
        generator = Generators::Create.new(session, location, copylist)
        generator.generate
      end
    end
=end
