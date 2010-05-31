require 'plugin'

module Sow

  # The Manager class manages and locates sow scaffolds.
  #
  class Manager

    SOURCE_DIRS = XDG::Config.select('/sow/sources/')

    #
    def initialize(options)
      @options = options
    end

    attr :options

    #
    def sources
      @sources ||= SOURCE_DIRS.map{ |dir| Dir[dir + '/*/'] }.flatten
    end

    #
    def find_scaffold(name)
      #case name
      #when /^git:/
      #  source = File.join(Dir.tmpdir, 'sow', File.basename(uri))
      #  `git clone #{uri} #{source}`
      #when /^svn:/
      #  source = File.join(Dir.tmpdir, 'sow', File.basename(uri))
      #  `svn checkout clone #{uri} #{source}`
      #else
        source = nil
        source ||= find_source(name)
        source ||= ::Plugin.find(File.join('sow', name)).first
      #end
      raise "Can't find #{name} scaffold." unless source
      Pathname.new(source)
    end

    #
    def find_source(name)
      dir = nil
      src = sources.find do |source|
        dir = File.join(source,name)
        File.directory?(dir)
      end
      src ? File.join(src,name) : nil
    end

    #
    def list
      l = sources.map{ |source| Dir[File.join(source, '*/')] }.flatten
      l.map{ |f| File.chomp('/').basename(f) }
    end

    #
    def install(resource)
      dir  = XDG::Config.home + '/sow/sources/'
      name = File.basename(resource).chomp(File.extname(resource))
      dest = File.join(dir, name)
      if File.exist?(dest)
        raise "#{dest} already exists"
      end
      case resource
      when /^git\:/, /\.git$/
        cmd = "git clone #{resource} #{dest}"
      when /^svn\:/
        cmd = "svn checkout clone #{resource} #{dest}"
      else
        cmd = "ln -s #{resource} #{dest}"
      end
      if options.trial
        $stderr.puts(cmd)
      else
        `#{cmd}`
      end
    end

    #
    def update(name)
      dir  = XDG::Config.home('sow/sources/')
      dest = File.join(dir, name)
      if !File.exist?(dest)
        raise '#{dest} does not exists'
      end
      if File.exist?(File.join(dest, '.git'))
        cmd = "cd #{dest}; git pull origin master"
      elsif File.exist?(File.join(dest, '.svn'))
        cmd = "cd #{dest}; svn update"
      end
      if options.trial
        $stderr.puts(cmd)
      else
        `#{cmd}`
      end
    end

    #
    def uninstall(resource)
      dir  = XDG::Config.home('sow/sources/')
      name = File.basename(resource).chomp(File.extname(resource))
      dest = File.join(dir, name)
      #FileUtils.rm_rf(dest)
    end

=begin
    # Plugins
    #--
    # Note that order of paths is important here.
    #++
    def plugin_locations
      @plugin_locations ||= (
        pl = {}
        pa = []
        pa |= plugins_from_packages
       #pa |= plugins_core)
       #pa |= plugins_user
        pa.each do |d|
          pl[File.basename(d)] = d
        end
        pl
      )
    end

    def plugins
      @plugins ||= plugin_locations.keys
    end

    def plugin(session, name, options)
      location = plugin_locations[name]
      raise "unknown scaffolding -- #{name}" unless location
      Plugin.new(session, location, options)
    end

    # Convert path into plugin.
    #def plugin(path)
    #  path = Pathname.new(path) unless path.is_a?(Pathname)
    #  Plugin.new(:location => path, :project => project, :command => cli)
    #end

    # This routine searches for seeds (sow plugins),
    #
    def plugins_from_packages
      match = File.join(PLUGIN_DIRECTORY, '*/')
      PluginManager.find(match).map do |path|
        path.chomp('/')
      end
    end
=end

  end

end #module Sow

