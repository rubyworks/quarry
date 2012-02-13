require 'sow/core_ext'
#require 'sow/config'
require 'sow/manager'

module Sow

  # A Seed encapsulates the location in the file system of the scaffolding.
  #
  class Seed

    # Basenames of files to ignore in template files.
    IGNORE = %w{. .. .svn _}

    # Files to remove in template files.
    #REMOVE = [CTRL]

    #
    MARKER = '.seed'

    #
    COPY_SCRIPT = "#{MARKER}/copy.rb"

    #
    README_FILE = "#{MARKER}/README{,.*}"

    # Find a seed by +name+.
    def self.find(name)
      manager.find_seed(name)
    end

    # Reterun an instance of a seed manager.
    def self.manager
      @manager ||= Manager.new
    end

    #def self.load(name)
    #  path = find(name)
    #  raise "No seed -- #{name}" unless path
    #  new(path)
    #end

    #
    # Initialize new seed.
    #
    # @param [String] path
    #   Location of the seed in the file system.
    #
    def initialize(path, options={})
      @path = Pathname.new(path)
      @type = options[:type].to_s

      @copyfile = Dir[File.join(@path, COPY_SCRIPT)].first
      @readme   = Dir[File.join(@path, README_FILE)].first  

      raise "not a seed - #{name}" unless (@path + MARKER).exist?
    end

    #
    attr :type

    #
    # The name of a seed is essentially the directory in which
    # it is store, but modified to be more utlitilitarian to the
    # end user when specifying a seed on the command line.
    #
    # @return [String] Name of seed.
    #
    def name
      @name ||= (
        rpath = path.to_s.sub(/^#{location}/, '')
        rpath = rpath[1..-1] if rpath.start_with?('/')

        return rpath

        i = rpath.index('/')
        if i
          base = rpath.to_s[0...i]
          name = rpath.to_s[i+1..-1]
          "#{name}@#{base}"
        else
          rpath
        end
        #rpath = path.to_s.sub(/^#{location}/, '')
        #parts = rpath.split('/')  
        #parts.reverse.join('.').chomp('.')
      )
    end

    #
    # The type of seed determines where it is located.
    #
    def location
      case type
      when 'bank'
        Manager.bank_folder
      #when 'silo'
      #  Manager.silo_folder
      when 'work'  # should be output dir ?
        Dir.pwd
      when 'plugin'
        path.to_s[0..path.to_s.rindex('/sow')+4]
      else
        path.to_s[0..path.to_s.rindex('/sow')+4]
      end
    end

    #
    # Location of seed.
    #
    def path
      @path
    end

    #
    #
    #
    alias_method :directory, :path

    #
    # Full file system path to the seed's copy script.
    #
    # @return [String] Full path to copy file.
    #
    def copyfile
      @copyfile
    end

    #
    # Read the `sowfile.rb` script.
    #
    def script
      @script ||= (
        s = File.read(copyfile).strip
        s.empty? ? "copy '**/*'" : s   # don't really need this
      )
    end

    #
    # Returns the list of seed files, less files to ignore.
    #
    # @return [Array] List of files.
    #
    def files
      @files ||= (
        files = []
        Dir.recurse(directory.to_s) do |path|
          next if IGNORE.include?(File.basename(path))
          files << path.sub(directory.to_s+'/','')
        end
        files.reject{ |f| File.match?(COPYRB_PATTERN) || File.match?(README_PATTERN) }
      )
    end

    # Do it!
    #def sow!(selection, arguments, settings, options)
    #  Seeder.new(self, selection, arguments, settings, options)
    #  seeder.call
    #end

    #
    # Contents of the help text at top of Sowfile, if any.
    #
    def help
      if readme
        File.read(readme).strip
      else
        'No documentation.'
      end
    end

    #
    # Same as seed name.
    #
    def to_s
      name.to_s
    end

  end

end
