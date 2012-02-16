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
    def initialize(name, path, options={})
      @name      = polish(name)
      @directory = Directory.new(self, path)
      @type      = options[:type]

      #raise "not a template - #{name}" unless @config_file
    end

    #
    # The name of a template is essentially the directory in which
    # it is stored, but modified to be more utlitilitarian to the
    # end-user when referencing it on the command line. This is done
    # by spliting the path at the path dividers (`/`) and rejoining
    # themin reverse order with a dot (`.`).
    #
    # @return [String] Name of template.
    #
    attr :name

    #
    # Instance of Template::Directory.
    #
    attr :directory

    #
    # Type of template: `:remote`, `:project`, `:plugin`.
    #
    attr :type

    #
    # Location of template as Pathname.
    #
    # @return [Pathname] Template path.
    #
    def path
      @directory.path
    end

    #
    # Template configuration.
    #
    def config
      @config ||= Config.new(self)
    end

    #
    # @deprecated Use `config.file` instead.
    #
    def config_file
      config.file
    end

    #
    # Copy script. Defaults to `copy all`.
    #
    def script
      @script ||= Script.new(self)
    end

    #
    #
    #
    def readme
      @readme ||= Readme.new(self)
    end

    #
    # Contents of the README file.
    #
    def help(lang='en')
      readme.to_s(lang)
    end

    #
    # Returns the list of template files, less files to be ignored
    # for scaffolding.
    #
    # @return [Array] List of scaffolding files.
    #
    def files
      directory.files

      #@files ||= (
      #  files = []
      #  Dir.recurse(directory.to_s) do |path|
      #    next if IGNORE_FILES.include?(File.basename(path))
      #    files << path.sub(directory.to_s+'/','')
      #  end
      #  files.reject{ |f| File.match?(CONFIG_FILE) }
      #)
    end

    #
    # Returns the list of template directories, less those to be ignored
    # for scaffolding.
    #
    # @return [Array] List of scaffolding directories.
    #
    def directories
      directory.directoires
    end

=begin
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
=end

    # Do it!
    #def quarry!(selection, arguments, settings, options)
    #  Seeder.new(self, selection, arguments, settings, options)
    #  mineer.call
    #end

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

  private

    def polish(name)
      name.split('/').reverse.join('.')
    end

  end

end
