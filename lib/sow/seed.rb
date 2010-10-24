require 'sow/core_ext'
#require 'sow/config'
require 'sow/manager'

module Sow

  # A Seed is simpl the location in the file system of a Sowfile.
  class Seed

    # Basenames of files to ignore in template files.
    IGNORE = %w{. .. .svn}

    # Files to remove in template files.
    REMOVE = %w{Sowfile _Sowfile}

    #
    SOWFILE_PATTERN = '{_,}Sowfile'

    #
    SOWCTRL_PATTERN = '../{_,}Sowctrl'

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

    # New Seed.
    #
    # ## ARGUMENTS
    #
    #   * `name`:
    #     Name of the seed (or best prefix match).
    #
    def initialize(path, options={})
      @path = Pathname.new(path)
      @type = options[:type].to_s

      @sowfile = Dir[File.join(@path,SOWFILE_PATTERN)].first 
      @sowctrl = Dir[File.join(@path,SOWCTRL_PATTERN)].first

      raise "not a seed - #{name}" unless @sowfile
    end

    #
    attr :type

    # Name of seed.
    def name
      @name ||= (
        rpath = path.to_s.sub(/^#{location}/, '')
        parts = rpath.split('/')  
        parts.reverse.join('.').chomp('.')
      )
    end

    #
    def location
      case type
      when 'bank'
        Manager.bank_folder
      when 'silo'
        Manager.silo_folder
      when 'work'  # should be output dir ?
        Dir.pwd
      when 'plugin'
        path.to_s[0..path.to_s.rindex('/sow/')+4]
      else
        path.to_s[0..path.to_s.rindex('/sow/')+4]
      end
    end

    # Seed directory.
    def path
      @path
    end

    #
    alias_method :directory, :path

    # Full file system path to the seed's Sowfile.
    #
    #   `sowfile() -> String`
    #
    def sowfile
      @sowfile
    end

    #
    def sowctrl
      @sowctrl
    end

    #
    def script
      @script ||= (
        s = ""
        if sowctrl
          s << File.read(sowctrl)
          s << "\n"
        end
        s << File.read(sowfile)
        s.strip!
        s.empty? ? "copy '**/*'" : s   # don't really need this
      )
    end

    # Returns the list of seed files, less files to ignore.
    #
    #   `files() -> Array`
    #
    def files
      @files ||= (
        files = []
        Dir.recurse(directory.to_s) do |path|
          next if IGNORE.include?(File.basename(path))
          files << path.sub(directory.to_s+'/','')
        end
        files - REMOVE
      )
    end

    # Do it!
    #def sow!(selection, arguments, settings, options)
    #  Seeder.new(self, selection, arguments, settings, options)
    #  seeder.call
    #end

    def help
      docs = false
      text = ""
      File.readlines(sowfile).each do |line|
        if docs
          break if line !~ /^\#/
          text << line
        else
          next  if line =~ /^\#\!/
          next  if line =~ /^\s*$/
          break if line !~ /^\#/
          text << line
          docs = true
        end
      end
      text
    end

    #
    def to_s
      name.to_s
    end

  end

end

