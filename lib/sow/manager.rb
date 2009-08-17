require 'sow/plugin'

module Sow

  # The Manager class locates sow plugins.
  class Manager

    def initialize
    end

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
       #pa |= plugins_custom
        pa.each do |d|
          pl[File.basename(d).chomp('.sow')] = d
        end
        pl
      )
    end

    def plugins
      @plugins ||= plugin_locations.keys
    end

    def plugin(name, arguments, options)
      location = plugin_locations[name]
      raise "unknown scaffolding -- #{name}" unless location
      Plugin.new(location, arguments, options)
    end

    # Convert path into plugin.
    #def plugin(path)
    #  path = Pathname.new(path) unless path.is_a?(Pathname)
    #  Plugin.new(:location => path, :project => project, :command => cli)
    #end

    # Plugins installed in other packages.
    # This routine searches through the $LOAD_PATH
    # looking for directories with a MANIFEST.sow file.
    #
    def plugins_from_packages
      paths = []

      # standard load path
      $LOAD_PATH.uniq.each do |path|
        dirs = Dir.glob(File.join(path, '**', '*.sow/'))
        dirs = dirs.select{ |d| File.directory?(d) }
        dirs = dirs.map{ |d| d.chomp('/') }
        paths.concat(dirs) 
      end

      # rolls
      if defined?(::Roll)
        ::Roll::Library.ledger.each do |name, lib|
          lib = lib.sort.first if Array===lib
          lib.load_path.each do |path|
            path = File.join(lib.location, path)
            dirs = Dir.glob(File.join(path, '**', '*.sow/'))
            dirs = dirs.select{ |d| File.directory?(d) }
            dirs = dirs.map{ |d| d.chomp('/') }
            paths.concat(dirs)
          end
        end
      end

      #if defined?(::Gem)
      #  Gem.find_files('*.sow').reverse_each do |path|
      #    if File.directory?(path)
      #      paths << path
      #    end
      #  end
      #end

      paths
    end

  end

end

