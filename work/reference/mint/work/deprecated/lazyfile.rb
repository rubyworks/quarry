  # Scaffold Builder is a specialized class that acts
  # as a restricted space with a limited command set
  # for preforming scaffolding.
  #
  # The default behavior is simply to copy all the contents
  # of the selected scaffold to the currrent directory.
  # But if a scaffold.rb file is provided with the scaffolding
  # this script will be run in the Builder context instead.

  class Builder

    def self.create( folder, options=nil )
      i = new
      Dir.chdir(folder) do
        if File.exist?('scaffold.rb')
          code = "def self.install( options=nil )\n" << File.read('scaffold.rb') << "\nend"
          i.instance_eval code
        end
        i.install( options.to_openobject )
      end
      return *i.results
    end

    # FIXME Need to improve undefining most instance methods for this context.
    instance_methods.each{ |m| undef_method m unless m =~ /__|send|class|object|instance/ }

    def initialize( options=nil )
      @note  = []
      @dirs  = []
      @copy  = {}
    end

    # Return results.

    def results
      return @note, @dirs, @copy
    end

    # Change directory in project as it is being build.
    # This makes it easy to conditionally build tiers of
    # structure.

    def cd( dir )
      if dir == '..'
        @cwd = File.dirname(@cdir)
      else
        @cwd = [@cwd,dir].to_path
      end
    end

    # Make a new project directory.

    def mkdir(dir)
      @dirs << [@cwd,dir].to_path
    end

    # Copy +glob+ of files from scaffolding +dir+ to project.
    #
    # If +to+ is omitted copies the files as named.
    # If +to+ is given then the files are renamed or
    # relocated accordingly. Use '*' in +to+ to substitute
    # for the file name. For example:
    #
    #   copy 'standard', '**/*, 'src/*'
    #
    # This would copy all the files in the scaffoldings subdirectory,
    # +standard/+, to the project directory +src/+.

    def copy(dir, glob, to=nil)
      Dir.chdir(dir) do
        Dir.glob(glob).collect do |file|
          if File.file?(file)
            from = File.join(dir, file)
            if to
              tofile = [@cwd, to.gsub('*', file)].to_path
            else
              tofile = [@cwd, file].to_path
            end
            @copy[from] = tofile
          else
            @dirs << [@cwd, file].to_path
          end
        end
      end
    end

    def note( str )
      @note << str
    end

    # default installation routine

    def install( options=nil )
      copy '.', '**/*'
    end

  end
