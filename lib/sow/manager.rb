require 'plugin'

module Sow

  # The Manager class manages and locates sow scaffolds.
  #
  class Manager

    # Location of sources. These are stored in $XDG_CONFIG_DIRS/sow/sources/.
    SOURCE_DIRS = XDG::Config.select('/sow/seeds')

    # User seeds.
    HOME = Pathname.new(XDG::Config.home + '/sow/seeds')

    #
    def initialize(options)
      @options = options
    end

    #
    attr :options

    #
    def sources
      @sources ||= SOURCE_DIRS #.map{ |dir| Dir[dir + '/*/'] }.flatten
    end

    #
    #def find_scaffold(name)
    #  source = nil
    #  source ||= find_source(name)
    #  source ||= ::Plugin.find(File.join('sow', name)).first
    #  raise "Can't find #{name} scaffold." unless source
    #  Pathname.new(source)
    #end

    #
    def find_scaffold(match)
      map.each do |name, dir|
        return dir if /^#{match}\./ =~ name
      end
      map.each do |name, dir|
        return dir if match == name
      end
      nil
      #dir = nil
      #src = sources.find do |source|
      #  dir = File.join(source,name)
      #  File.directory?(dir)
      #end
      #src ? File.join(src,name) : nil
    end

    #
    def list
      map.map{ |l| l.first }
    end

    #
    def map
      list = []
      # uri and linked sources
      sources.each do |source|
        locs = Dir[File.join(source, '**/template')]
        locs = locs.map{ |l| File.dirname(l) }
        locs.each do |l|
          k = path_to_name(l.sub(source,''))
          list << [k, l]
        end
      end
      # installed sow plugin seeds
      locs = ::Plugin.find(File.join('sow', '**/template'))
      locs = locs.map{ |l| File.dirname(l) }
      locs.each do |l|
        k = path_to_name(l[l.rindex('sow')+4..-1])
        list << [k, l]
      end
      list
    end

    # Lookup seed and and return the contents of it's
    # README file. If it does not have a README file
    # it will return 'No README'.
    def readme(resource)
      dir = find_scaffold(resource)
      if dir
        if file = File.join(dir, 'README')
          return File.read(file)
        end
      end
      return 'No README' unless dir
    end

    #
    def install(resource)
      dir  = HOME #Pathname.new(XDG::Config.home + '/sow/seeds/')
      out  = dir + uri_to_path(resource)
      name = File.basename(resource).chomp(File.extname(resource))
      if File.exist?(out + name)
        $stderr.puts "#{out + name} already exists"
        return # update ?
      end
      case resource
      when /^git\:/, /\.git$/
        cmd = "git clone #{resource} #{name}"
      when /^svn\:/
        cmd = "svn checkout clone #{resource} #{name}"
      else # local path
        cmd = "ln -s #{resource} #{out}"
      end
      if options.trial
        $stderr.puts("  mkdir -p #{out}")
        $stderr.puts("  cd #{out}")
        $stderr.puts("  #{cmd}")
      else
        FileUtils.mkdir_p(out)
        `cd #{out}; #{cmd}`
      end
    end

    #
    def uri_to_path(uri)
      uri = uri.dup
      uri.sub!(/^git\:\/\//, '')
      uri.sub!(/^svn\:\/\//, '')
      div = File.dirname(uri).split('/') # File::SEPARATOR ?
      div.reverse.join('.')
    end

    #
    def path_to_name(path)
      div  = path.split('/') # File::SEPARATOR ?
      name = div.reverse.join('.').chomp('.')
      if md = /default\./.match(name)
        name = md.post_match
      end
      name
    end

    #
    def update(resource=nil)
      dir = HOME #Pathname.new(XDG::Config.home + '/sow/seeds/')
      if resource
        out  = dir + uri_to_path(resource)
        if !out.exist
          raise '#{out} does not exists'
        end
        paths = [out]
      else
        paths = dir.glob('*')
      end
      paths.each do |out|
        if (out + '.git').exist?
          cmd = "cd #{out}; git pull origin master"
        elsif (out + '.svn').exist?
          cmd = "cd #{out}; svn update"
        end
        if options.trial
          $stderr.puts(cmd)
        else
          `#{cmd}`
        end
      end
    end

    # TODO
    def uninstall(resource)
      dir  = Pathname.new(XDG::Config.home + '/sow/seeds')
      out  = dir + uri_to_path(resource)
      #name = File.basename(resource).chomp(File.extname(resource))
      #dest = File.join(dir, name)
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
=end

  end

end #module Sow

