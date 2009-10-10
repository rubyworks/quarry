require 'sow/plugin'
require 'facets/plugin_manager'

module Sow

  # The Manager class locates sow plugins.
  #
  class Manager

    #
    PLUGIN_DIRECTORY = "sow/seeds"

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
        pa.each do |d|
          pl[File.basename(d)] = d
        end
        pl
      )
    end

    def plugins
      @plugins ||= plugin_locations.keys
    end

    def plugin(session, name, value, pathname)
      location = plugin_locations[name]
      raise "unknown scaffolding -- #{name}" unless location
      Plugin.new(session, location, value, pathname)
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

=begin
    # Plugins installed in other packages.
    # This routine searches through the $LOAD_PATH
    # looking for directories with a MANIFEST.sow file.
    #
    def plugins_from_packages
      plugins = []
      # Standard $LOAD_PATH
      $LOAD_PATH.uniq.each do |path|
        dirs = Dir.glob(File.join(path, PLUGIN_DIRECTORY, '*/'))
        #dirs = dirs.select{ |d| File.directory?(d) }
        dirs = dirs.map{ |d| d.chomp('/') }
        plugins.concat(dirs)
      end
      # ROLL (load latest versions only)
      if defined?(::Roll)
        ::Roll::Library.ledger.each do |name, lib|
          lib = lib.sort.first if Array===lib
          lib.load_path.each do |path|
            path = File.join(lib.location, path)
            dirs = Dir.glob(File.join(path, PLUGIN_DIRECTORY, '*/'))
            #dirs = dirs.select{ |d| File.directory?(d) }
            dirs = dirs.map{ |d| d.chomp('/') }
            plugins.concat(dirs)
          end
        end
      end
      # RubyGems (load latest versions only)
      if defined?(::Gem)
        Gem.latest_load_paths do |path|
          dirs = Dir.glob(File.join(path, PLUGIN_DIRECTORY, '*/'))
          dirs = dirs.map{ |d| d.chomp('/') }
          plugins.concat(dirs)
        end
      end
      plugins
    end
=end

  end

end #module Sow

