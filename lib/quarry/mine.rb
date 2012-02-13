require 'quarry/core_ext'
#require 'quarry/config'
require 'quarry/manager'

module Quarry

  # Encapsulates a location in the file system to be used as scaffolding.
  #
  # In Quarry terminology we call it a "mine".
  #
  class Mine

    # Find a mine by +name+.
    def self.find(name)
      manager.find(name)
    end

    # Reterun an instance of a mine manager.
    def self.manager
      @manager ||= Manager.new
    end

    #def self.load(name)
    #  path = find(name)
    #  raise "No mine -- #{name}" unless path
    #  new(path)
    #end

    #
    # Initialize new mine.
    #
    # @param [String] path
    #   Location of the mine in the file system.
    #
    def initialize(path, options={})
      @path = Pathname.new(path)
      @type = options[:type].to_s

      @copyfile = Dir[File.join(@path, COPY_SCRIPT)].first
      @readme   = Dir[File.join(@path, README_FILE)].first  

      raise "not a mine - #{name}" unless (@path + SCAFFOLD_MARKER).exist?
    end

    #
    attr :type

    #
    # The name of a mine is essentially the directory in which
    # it is store, but modified to be more utlitilitarian to the
    # end user when specifying a mine on the command line.
    #
    # @return [String] Name of mine.
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
    # The type of mine determines where it is located.
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
        path.to_s[0..path.to_s.rindex('/quarry')+7]
      else
        path.to_s[0..path.to_s.rindex('/quarry')+7]
      end
    end

    #
    # Location of mine.
    #
    def path
      @path
    end

    #
    #
    #
    alias_method :directory, :path

    #
    # Full file system path to the mine's copy script.
    #
    # @return [String] Full path to copy file.
    #
    def copyfile
      @copyfile
    end

    #
    # Read the `copy.rb` script.
    #
    def script
      @script ||= (
        s = File.read(copyfile).strip
        s.empty? ? "copy '**/*'" : s   # don't really need this
      )
    end

    #
    # Returns the list of mine files, less files to ignore.
    #
    # @return [Array] List of files.
    #
    def files
      @files ||= (
        files = []
        Dir.recurse(directory.to_s) do |path|
          next if SCAFFOLD_IGNORE.include?(File.basename(path))
          files << path.sub(directory.to_s+'/','')
        end
        files.reject{ |f| File.match?(COPY_SCRIPT) || File.match?(README_FILE) }
      )
    end

    # Do it!
    #def quarry!(selection, arguments, settings, options)
    #  Seeder.new(self, selection, arguments, settings, options)
    #  mineer.call
    #end

    #
    # Contents of the README file.
    #
    def help
      if readme
        File.read(readme).strip
      else
        'No documentation.'
      end
    end

    #
    # Same as mine name.
    #
    def to_s
      name.to_s
    end

  end

end
