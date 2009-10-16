require 'erb'
require 'fileutils'
require 'pathname'

require 'sow/extensions'
require 'sow/common'
require 'sow/metadata'
require 'sow/template'

#--
# TODO: When scaffolding new project, consider if metadata files might be generated first and then loaded.
#       This would allow all metadata entries to be used when scaffolding a new project.
#
# TODO: Could we use an "environment" settings file to specify environment variables to check for template variables?
#++

module Sow
module Construct

  ### = Create
  ###
  ### The Constructor class takes a generator and process it.
  ### It provides the backbone of Sow's operations.
  class Create
    attr :generator
    attr :runmode

    def initialize(generator, logger)
      @generator  = generator
      @logger     = logger
      @runmode    = logger.runmode
    end

    ###
    def metadata ; generator.metadata ; end

    ###
    def directory ; generator.directory ; end

    ###
    def source ; generator.source ; end

    ### Main command called to generate files.
    def generate(args, opts)
      generator.confirm?
      generator.setup(args, opts)

      manifest = generator.manifest
      manifest = expand_manifest(manifest)
      manifest = safe_manifest(manifest)

      check_manifest(manifest)  # TODO: should this come before or after safe_manifest ?
      check_overwrite(manifest)

      if manifest.empty?
        logger.report_nothing_to_generate
        return
      end

      Dir.chdir(directory) do
        logger.report_startup

        manifest.each do |action, tname, fname|
          atime = Time.now

          tpath = File.join(source, tname)
          text  = File.extname(tname)

          if File.directory?(tpath)
            result = send("#{action}_dir", tname, fname)
          else
            result = send("#{action}_file", tname, fname)
          end

          logger.report_create(fname, result, atime)
        end

        logger.report_complete
      end
    end

    def report(message)
      logger.report(message)
    end

  private

    def expand_manifest(manifest)
      expanded = []
      generator.manifest.each do |action, template, saveas|
        # complete destination file name if same as template name (ie. nil).
        saveas ||= template_to_filename(template)

        srcs = []
        srcs = Dir.chdir(source){ srcs = Dir.glob(template) }
        srcs = generator.filter(srcs)
        srcs.each do |src|
          expanded << [action, src.to_s, saveas.to_s]
        end
      end
p expanded
exit
      expanded
    end

    ### If safe mode, returns a manifest filtered of overwrites, as selected by the user.
    ### If not in safe mode, simply return the current manifest.
    def safe_manifest(manifest)
      return manifest unless safe?

      safe = []
      dups = []

      manifest.each do |action, tname, fname|
        dups << [action, tname, fname, (directory + fname).exist?]
      end     

      unless dups.empty?
        puts "Select (y/n) which files to overwrite:\n" unless quiet?
        dups.each do |action, tname, fname, check|
          if check
            case ans = ask("      #{fname}? ").downcase.strip
            when 'y', 'yes'
              safe << [action, tname, fname]
            else
              safe << [:skip, tname, fname]
            end
          else
            safe << [action, tname, fname]
          end
        end
      end
      return safe
    end

    # Check for any overwrites. If generator allows overwrites
    # this will be skipped, otherewise an error will be raised.

    def check_overwrite(manifest)
      return if force?
      return if safe?
      return if generator.overwrite?

      if generator.scaffold? && !generator.empty?
        abort "New project isn't empty. Use --force, --skip or --safe."
      end

      manifest.each do |action, tname, fname|
        tpath = source + tname
        fpath = directory + fname
        if File.exist?(fpath)
          abort "File #{fname} would be overwriten, use --force, --skip or --safe."
        end
      end
    end

    # Check for any clashing generations, ie. a directory that
    # will overwrite a file or a file that will overwrite a
    # directory. This will raise an error if any of these
    # conditions are found, unless force? is set to true.

    def check_manifest(manifest)
      return if force?
      manifest.each do |action, tname, fname|
        tpath = source + tname
        fpath = directory + fname
        if File.exist?(fpath)
          if tpath.directory?
            if !fpath.directory?
              raise "Directory to be created clashes with a pre-existent file -- #{fname}"
            end
          else
            if fpath.directory?
              raise "File to be created clashes with a pre-existent directory -- #{fname}"
            end
          end
        end
      end
    end

    ###
    def skip_dir(tname, fname)
      return 'skip'
    end

    ###
    def skip_file(tname, fname)
      return 'skip'
    end

    ### Copy a directory. Acually, this just does mkdir_p.
    def copy_dir(tname, fname)
      if File.exist?(fname)
        #logger.report_create(fname, 'identical')
        'identical'
      else
        #logger.report_create(fname, 'create')
        mkdir_p(fname)
        'create'
      end
    end

    ### Copy a file.
    def copy_file(tname, fname)
      #ext = File.extname(tname)
      doc = File.join(source, tname)
      if File.exist?(fname)
        how = 'update'
      else
        how = 'create'
      end
      #file = tmp_file.chomp('.stub')
      #file = file.sub('__name__', name)
      cp(doc, fname)
      return how
    end

    ### Template a directory.
    def template_dir(tname, fname)
      if File.exist?(fname)
        #logger.report_create(fname, 'identical')
        'identical'
      else
        #logger.report_create(fname, 'create')
        mkdir_p(fname)
        'create'
      end
    end

    ### Template a file.
    def template_file(tname, fname)
      ext = File.extname(tname)
      doc = File.join(source, tname)
      how = (File.exist?(fname) ? 'update' : 'create')
      case ext
      when '.erb'
        #file = tname.chomp('.erb')
        #file = file.sub('__name__', name)
        #logger.report_create(fname, how)
        text = process_erb(doc)
        write(fname, text)
      else
        #file = tmp_file.chomp('.stub')
        #file = file.sub('__name__', name)
        #logger.report_create(fname, how)
        cp(doc, fname)
      end
      return how
    end

    ### Convert a template pathname into a destination pathname.
    ### This allows for substitution in the pathnames themselves
    ### by using __name__ notation.
    def template_to_filename(tname)
      fname = tname.chomp('.erb')
      fname.sub('__name__', metadata.name)
    end

    ### Processes an erb template.
    def process_erb(file)
      env = Template.new(metadata)
      erb = ERB.new(File.read(file))
      begin
        txt = erb.result(env.get_binding)
      rescue => e
        if trace?
          raise e
        else
          abort "template error -- #{file}"
        end
      end
      return txt
    end

    ### Access to FileUtils
    def fu
      dryrun? ? FileUtils::DryRun : FileUtils
    end

    ### Write file.
    def write(file, text)
      if dryrun?
        puts "[dryrun] write #{file}"
      else
        File.open(file, 'w'){ |f| f << text }
      end
    end

    def mkdir_p(*args) ; fu.mkdir_p(*args) ; end
    def cp(*args)      ; fu.cp(*args)      ; end
    def mv(*args)      ; fu.mv(*args)      ; end

    def dryrun?   ; @runmode.dryrun?    ; end
    def noharm?   ; @runmode.noharm?    ; end
    def trace?    ; @runmode.trace?     ; end
    def quiet?    ; @runmode.quiet?     ; end
    def force?    ; @runmode.force?     ; end
    def safe?     ; @runmode.safe?      ; end
  end

end
end

