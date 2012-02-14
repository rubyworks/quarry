module Quarry

  # Template encapsulates a directory to be used as scaffolding.
  #
  # In Quarry's colloquial terminology this may be called a *mine*.
  #
  class Template

    #
    # Initialize new template.
    #
    # @param [String] path
    #   Location of the template in the file system.
    #
    def initialize(path, options={})
      @path = Pathname.new(path)
      @type = options[:type].to_s

      @config_file = Dir.glob(@path + CONFIG_FILE).first

      #raise "not a template - #{name}" unless @config_file

      if @config_file
        @config = YAML.load_file(@config_file)
      else
        @config = {}
      end
    end

    #
    # Type of template: bank, work, plugin
    #
    attr :type

    #
    # Location of template as Pathname.
    #
    # @return [Pathname] Template path.
    #
    attr :path

    #
    # Returns the list of template files, less files to be ignored
    # for scaffolding.
    #
    # @return [Array] List of scaffolding files.
    #
    def files
      @files ||= (
        files = []
        Dir.recurse(directory.to_s) do |path|
          next if IGNORE_FILES.include?(File.basename(path))
          files << path.sub(directory.to_s+'/','')
        end
        files.reject{ |f| File.match?(CONFIG_FILE) }
      )
    end

    #
    #
    #
    def config_file
      @config_file
    end

    #
    # The name of a tempalte is essentially the directory in which
    # it is stored, but modified to be more utlitilitarian to the
    # end-user when specifying it on the command line.
    #
    # @return [String] Name of template.
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
    # The type of template determines where it is located.
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
    # Script section of config file. Defaults to `copy all`.
    #
    def script
      #@script ||= (
        text = @config['script'] || 'copy all'  # TODO: do we even need the copy all ?
      #  Script.new(text)
      #)
    end

    # Do it!
    #def quarry!(selection, arguments, settings, options)
    #  Seeder.new(self, selection, arguments, settings, options)
    #  mineer.call
    #end

    def readme
      @readme ||= (
        doc = config['readme'] || config['README']
        Readme.new(doc)
      )
    end

    #
    # Contents of the README file.
    #
    def help
      readme.to_s
    end

    #
    # Same as template name.
    #
    def to_s
      name.to_s
    end

    #
    #
    #
    def update
      begin
        scm = SCM.new(directory.to_s)
        scm.pull(:force=>true)
      rescue ArgumentError
        # not a scm repo
      end
    end

  end

end
