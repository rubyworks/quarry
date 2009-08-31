require 'facets/ostruct'

require 'sow/session'
require 'sow/logger'
require 'sow/script'
require 'sow/generators/create'
require 'sow/generators/update'
require 'sow/generators/delete'

module Sow

  # = Plugin Controller
  #
  class Plugin

    # Name of plugin script file.
    SCRIPT_NAME = 'script.sow.rb'

    # Filter these files out of any scaffolding operation.
    FILTER = [ SCRIPT_NAME ] #, /USAGE\.txt/ ]

    # Instanance of Session.
    attr :session

    # Location of plugin.
    attr :location

    # An alias for location.
    alias_method :source, :location

    # Plugin's script.
    attr :script

    #
    def initialize(session, location, value, pathname)
      @session  = session
      @pathname = Pathname.new(pathname)
      @location = Pathname.new(location)
      @script   = Script.new(value, pathname) #(info) ?
      read_script
    end

    # Filter these files out of any scaffolding operation.
    def filter
      FILTER
    end

    # Metadata from scaffold destination.
    def metadata
      session.metadata
    end

    # Read and eval plugin script.
    def read_script
      file = File.join(location, SCRIPT_NAME)
      code = File.read(file)
      script.instance_eval(code, file)
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

    def setup #_for(type, argument, options)
      setup_arguments #(arguments)
      setup_metadata
      setup_script #(session)
    end

    # And arguments defined in the script get there assigments
    # defined as singleton methods via the script[]= call.
    def setup_arguments #(a)
      #h = {}
      a = script[:values]
      script[:arguments].each_with_index do |(name, desc, valid), i|
        if valid
          script[name] = valid.call(a[i])
        else
          script[name] = a[i]
        end
      end
      #@args = h #TODO: where?
    end

    # Collect any metadata settings that may have been made
    # in the initial script evaluation.
    def setup_metadata
      script.metadata.each do |k,v|
        metadata[k] = v
      end
    end

    # Setup the plugin with information about current operation.
    #
    # TODO: This seems wrong. Need to figure a better way!
    #
    def setup_script
      script.instance_variable_set("@session", session)
      script.instance_variable_set("@metadata", metadata)
      #script[:values].each do |v|
      #end
    end

    # Expanded copylist.
    def copylist
      @copylist ||= (
        copylist_sort(copylist_glob(script_copylist))
      )  #redest(list)
    end

    # Raw copylist as defined in the script.
    def script_copylist
      @script_copylist ||= (
        script[:copytemp].each{|s| s.call}
        script[:copylist]
      )
    end

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

    # Does the script define a package name.
    #def name
    #  script[:name]
    #end

    # Expand copylist by globbing entries.
    def copylist_glob(list)
      allfiles = []
      dotpaths = ['.', '..']
      list.each do |match, into, opts|
        from = opts[:cd] || '.'
        srcs = []
        Dir.chdir(source + from) do
          srcs = Dir.glob(match, File::FNM_DOTMATCH)
          srcs = srcs.reject{ |d| File.basename(d) =~ /^[.]{1,2}$/ }
        end
        srcs = filter_paths(srcs)
        srcs.each do |src|
          case into
          when /\/$/
            dest = File.join(into, File.basename(src))
          when '.'
            dest = src
          else
            dest = into
          end
          from_src = (from == '.' ? src : File.join(from, src))
          allfiles << [location, from_src, template_to_filename(dest), opts] #dest
        end
      end
      allfiles.reverse.uniq.reverse
      #allfiles.map do |f, t|
        #if File.directory?(t)
        #  [f, File.join(t, File.basename(f))]
        #else
      #    [f,t]
        #end
      #end
    end

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

    # Convert a template pathname into a destination pathname.
    # This allows for substitution in the pathnames themselves
    # by using '__name__' notation.
    #
    def template_to_filename(template)
      name = template.dup #chomp('.erb')
      name = name.gsub(/__(.*?)__/) do |md|
        metadata.__send__($1)
      end
      #if md =~ /^(.*?)[-]$/
      #  name = metadata[md[1]] || plugin.metadata(md[1]) || name
      #end
      name
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

    # Sort the list, directory before files and in alphabetical order.
    def copylist_sort(list)
      dirs, files = *copylist_partition(list)
      dirs.sort{|a,b| a[2]<=>b[2]} + files.sort{|a,b| a[2]<=>b[2]}
    end

    # Partition the list between directories and files.
    def copylist_partition(list)
      list.partition{ |loc, src, dest, opts| (loc + src).directory? }
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

end#module Sow

