# = scaffold.rb
#
# TODO Generalize scaffolding for arbitrary parts (?)

require 'rbconfig'
require 'tmpdir'
#require 'open-uri'

#require 'ratchets/utility/compress'
require 'facets/core/array/to_path.rb'

require 'project/buildutils'

class Project

# The Scaffold module provides a means for building up new
# project layout, including all the typical standard
# directories and files, or other pre-packaged project parts.
#
# New project layouts are automatically built to standard
# specifications and can be wrapped in additional subversion
# and/or website layers.
#
# Project parts can be retrived from remote sources and will
# be automitacally decompressed and merged into the project.
# If a scaffold.rb file is included in the parts package then
# conditional building can take place.
#
# WARNING! This is a very new feature and should be used with
# the expectaton that it is not 100% bug-free, and will certainly
# warrent design changes in the future.

class Scaffolding < Toolset

  # Create a new conventional project layout.
  #
  # Generates a project directory layout within the current
  # directory. The scaffolding includes all the standard
  # features such as directories lib/ bin/ doc/
  # and files such as README.
  #
  # To use this task you need to first create an new empty
  # directory and change into it. This command will not
  # create a new project directory for you. As a safegaurd,
  # this command will not generate scaffolding in a directory
  # with files already present, unless you use the -f (force)
  # option.
  #
  # You can specify a subversion layout by setting +svn+ to
  # true. You can also specify a web layout via the by setting
  # +web+ to true.

  def new( opts={} )
    opts = opts.to_options

    if project_content? and not opts.force
      puts "Directory already has content. Use -f option to force new scaffolding."
      return
    end

    # change 'standard' to 'ruby' in case other languages may
    # be supported in future?
    type = opts.type || 'standard'
    web  = opts.web
    svn  = opts.svn  || opts.subversion

    type = 'standard' if type == 'std'

    if file = project_file?
      file = File.expand_path(file)
    else
      file = form()
      file = File.expand_path(file)
      if ENV['EDITOR']
        system "#{ENV['EDITOR']} #{file}"
      end
    end

    proj = YAML::load(File.open(file))

    # set scaffolding dir
    dir = File.join( datadir, 'scaffolds' )

    if web
      from = File.join(dir, 'website', '.')
      cp_r(from, '.')
      cd('src')
    end

    if svn
      mkdir_p('branches')
      mkdir_p('tags')
      mkdir_p('trunk')
      cd('trunk')
    end

    # copies standard project layout from Ratchets' data dir
    from = File.join(dir, 'standard', '.')
    cp_r(from, '.')

    # if project use project info to improve scaffolding
    if proj
      mkdir_p("lib/#{proj['name']}")
      mkdir_p("data/#{proj['name']}")

      #unless project.dryrun?
      #  bdir = Dir.pwd
      #  bdir.sub!(File.dirname(file) + '/','')
      #  File.open(file,'a') do |f|
      #   f << "basedir: #{bdir}"
      #  end
      #end

      # move project file to source folder if differnt
      mv(file,'.') unless Dir.pwd == File.dirname(file)
    else
      # create project information file
      form
    end

    puts "Project ready."
  end

  # Create a project part.

  def part( opts )
    puts "part system not yet implmented"
  end

  # Creates a ProjectInfo file in the current directory.
  # It will not overwrite a ProjectInfo file if one is already
  # present. The file can be named ProjectInfo, PROJECT or
  # project.yaml.

  def form( opts={} )
    opts = opts.to_options

    name = opts.name || 'ProjectInfo'

    if name !~ /project(info)?(.yaml|.yml)?/i
      raise ArgumentError, "not a recognized project information file name"
    end

    f = nil
    files = Dir.glob("{[Pp]roject,PROJECT}{INFO,[Ii]nfo,.yml,.yaml,}")
    if f = files[0]
      puts "Project file '#{f}' already exists."
      return
    end

    file = File.join(datadir, 'scaffolds', 'project.yaml')
    install(file, name)

    unless opts.noharm
      File.open(name,'a') do |f|
        date = Time.now.strftime("%Y-%m-%d")
        f << "created: #{date}"
      end
    end

    unless opts.quiet
      puts "Created '#{name}'."
      puts "Please edit to suit your project."
    end

    return name
  end

  private

  # Is there a project information file?

  def project_file?
    f = nil
    files = Dir.glob("{[Pp]roject,PROJECT}{INFO,[Ii]nfo,.yml,.yaml,}")
    return files[0]
  end

  # Project contains content?

  def project_content?
    content = Dir.entries('.') - ['.', '..']
    content -= [project_file?]
    return !content.empty?
  end

end # end Scaffolding

end # class Project









#   def seed( keys, &yld )
#     keys = (keys||yld).to_openobject
#
#     name = keys.name
#     type = keys.type
#     site = keys.site
#     meta = keys.meta
#     web  = keys.web
#
#     raise ArgumentError, "missing field -- name or type" unless name
#
#     if site
#       url = File.join(site, name)
#       scaffold(url, keys)
#     else
#       case name.to_s.downcase
#       when 'std', 'standard', 'svn', 'subversion'
#         new_project(keys)
#       when 'project', 'projectinfo', 'project.yaml', 'project.yml'
#         projectinfo_template(name, meta)
#       #when 'setup', 'setup.rb'
#       #  setup_rb
#       else
#         url = File.join( Ratchets.datadir, 'scaffolding', name )
#         scaffold(url, keys)
#       end
#     end
#   end
# 
#   private


#   def new_project( keys, &yld )
#     keys = (keys||yld).to_openobject
# 
#     type = keys.type || keys.name
#     meta = keys.meta
#     web  = keys.web
# 
#     raise ArgumentError, "Must supply new project type." unless type
# 
#     content = Dir.entries('.') - [ '.', '..' ]
#     if not content.empty? and not project.force?
#       puts "Directory already has content. Use -f option to force new scaffolding."
#       return nil
#     end
# 
#     local_store = File.join( Ratchets.datadir, 'scaffolding' )
# 
#     type = 'standard'   if type == 'std'
#     type = 'subversion' if type == 'svn'
# 
#     if web
#       from = File.join( local_store, 'website', '.' )
#       FileUtils.cp_r( from, '.' )
#       Dir.chdir( 'src' )
#     end
# 
#     if type == 'subversion' or type == 'svn'
#       mkdir_p( 'branches' )
#       mkdir_p( 'tags' )
#       mkdir_p( 'trunk' )
#       Dir.chdir( 'trunk' )
#     end
# 
#     # copies typical project layout
#     from = File.join( local_store, 'standard', '.' )
#     FileUtils.cp_r( from, '.' )
# 
#     # create project.yaml template.
#     projectinfo_template(nil,meta)
# 
#     puts "Project ready."
#   end

=begin
  # Generate pre-built targets in project's target folder.

  def targets( keys, &yld ) #( folder, targets=nil )
    keys = (keys||yld).to_openobject

    folder  = keys.folder || 'script'
    targets = keys.targets || keys.target

    match  = File.join(File.dirname(__FILE__), 'targets', '*')
    files  = Dir.glob(match)
    names  = files.collect{ |f| File.basename(f).chomp('.rb') }
    cross  = Hash[*names.zip(files).flatten]

    case targets
    when String
      targets = targets.split(',')
    when Array
      targets = [targets].flatten
    else
      targets = names
    end

    # only specific targets that exist?
    #targets = (AUTOTARGETS & targets)

    unless (diff=(targets-names)).empty?
      puts "project: unknown targets " + diff.join(',')
      return
    end

    mkdir_p(folder)
    targets.each do |name|
      file1 = cross[name]
      file2 = File.join(folder, name)
      unless (File.exist?(file2) or project.dryrun?)
        install(file1, file2, :mode=>0754)
      end
    end

    return folder
  end
=end
