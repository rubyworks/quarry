require 'erb'
require 'fileutils'
require 'pathname'

require 'sow/extensions'
require 'sow/common'
require 'sow/metadata'
require 'sow/template'

module Sow

  #
  class Generator
    #instance_methods.each{ |m| undef_method(m) unless m.to_s =~ /^(__|inspect$|instance_|object_)/ }

    ### The manifest is a list of file to be generated in the
    ### form of [action, from, to]. Eg.
    ###
    ###   [[:copy, 'test.rb', 'test/test_foo.rb']]
    ###
    attr :manifest

    #
    def initialize(location, runmode)
      @location  = Pathname.new(location)
      @runmode   = runmode
      @arguments = arguments.dup
      @options   = options.dup

      @work   = Pathname.new(Dir.pwd)
      @source = location + 'templates'

      if root = Sow.locate_root
        @new       = false
        @root      = Pathname.new(root)
        @output = Pathname.new(root)
        @metadata  = Metadata.load(root)
      else
        @new       = true
        @root      = Pathname.new(Dir.pwd)
        @output    = Pathname.new(Dir.pwd)
        @metadata  = Metadata.load
      end
    end

    ### For specialized generators, override this method.
    ### The default definition automatically templates
    ### all template file to corresponding locations in 
    ### the project.
    def setup(args=[], opts={})
      return @setup_block[args, opts] if setup_block

      # set selection
      selection = args.empty? ? nil : args
      # add templates
      templates(selection).each do |tname|
        template(tname) #, template_to_filename(tname))
      end
    end

    ### New scaffolding (as opposed to generation)?
    def new? ; @new ; end

    ### Is the output directory empty?
    def empty?
      Dir[output + '**/*'].empty?
    end

    ### Access to project metadata.
    def metadata ; @metadata ; end


    ### Location of the generator templates.
    def source(set=nil)
      @source = set if set
      @source
    end

    ### Base directory for where to put the scaffolding.
    ### The setting can be either :root or :work.
    ### The default is :root.
    def output(set=nil)
      return @output unless set
      case set
      when :root
        @output = root
      when :work
        @output = work
      else  
        raise ArgumentError, "must be :root or :work -- #{set}"
      end
    end

    ### Location of the current generator as a pathname.
    def local ; location ; end

    ### Location of the project root as a pathname.
    def root ; @root ; end

    ### Current working directory as a pathname.
    def work ; @work ; end

    # Returns pathname to current project's sow configuration directory.
    def admin
      @admin ||= root.glob('{,_}{admin}', File::FNM_CASEFOLD).first || root
    end

    ###
    def scaffold?  ; false ; end  #?

    ###
    def overwrite? ; false ; end

    ###
    def confirm?   ; true ; end

    ### Project's "unix" name. On new scaffolding this is the directory name
    ### filtered through #methodize. If not a new project, then of course, it set
    ### by the metadata.name value.
    #def project   ; @project   ; end

    FILTERS = [ /[.]svn/, /[.]gitigonore/ ]

    ### Returns list of all templates sorted alphabetically.
    def templates(selection=nil)
      return [] unless source
      selection ||= ['**/*']
      paths = []
      Dir.chdir(source) do
        paths = selection.collect{ |s| Dir.glob("#{s}{,.erb}", File::FNM_DOTMATCH) }.flatten.uniq
        paths = paths.reject{ |f| File.basename(f) == '.' || File.basename(f) == '..' }
        paths = filter(paths)
      end
      return paths.sort
    end

    ### Filter out special files/directories.
    def filter(paths)
      FILTERS.each do |filt|
        paths.reject{ |pn| filt =~ pn.to_s }
      end
    end




    ### Process template and copy result to destination.
    def template(template, dest=nil)
      #dest ||= template_to_filename(template)
      @manifest << [:template, template, dest]
    end

    ### Copy template verbatium to destination.
    ### If template is a directory, all content will be copied.
    def copy(template, dest=nil)
      @manifest << [:copy, template, dest]
    end
    alias_method :verbatim, :copy

    ### Make a directory.
    def mkdir(dir)
      @manifest << [:mkdir, nil, dir]
    end

    def directory(dir)
      @manifest << [:mkdir, nil, dir]
    end

  end

end

