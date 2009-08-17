require 'pathname'
require 'sow/core_ext'
require 'sow/plugin'
require 'sow/context'

module Sow

  module Generators

    # Base Class for the generators. This provides the
    # backbone of Sow's operations. Essentially a plugin
    # provides a manifest to the generator, which cleans
    # it up and uses it for it's specific task,
    # eg. create, update or destroy.
    #
    class Base

      attr :plugin

      #attr :metadata
      #attr :logger
      #attr :output

      #attr :runmode
      #attr :command  # best name for this ?

      def initialize(plugin)
        @plugin   = plugin
        #@metadata = plugin.metadata
        #@logger   = plugin.logger
        #@output   = plugin.output

        #@runmode = plugin.runmode
        #@command = plugin.command
      end

      def inspect
        "#<#{self.class} @plugin=#{@plugin.inspect}>"
      end

      def trial?  ; plugin.trial?  ; end
      def quiet?  ; plugin.quiet?  ; end
      def trace?  ; plugin.trace?  ; end
      def force?  ; plugin.force?  ; end
      def skip?   ; plugin.skip?   ; end
      def prompt? ; plugin.prompt? ; end

      #
      #def command
      #  plugin.command
      #end

      # Metadata provided by plugin.
      def metadata
        plugin.metadata
        #  plugin.context
      end

      # Metadata provided by plugin.
      def manifest
        plugin.manifest
      end

      # Metadata provided by plugin.
      def logger
        plugin.logger
      end

      # Where to place generated files.
      def output
        @output ||= Pathname.new(plugin.output)
      end

      # Where to find plugin templates.
      def location
        @location ||= Pathname.new(plugin.location)
      end
      alias_method :source, :location

      # Main command called to generate files.
      #
      def generate #(args, opts)
        plugin.prepare # prepare manifest copylist
        actionlist = manifest_prepare(manifest.copylist)
        if actionlist.empty?
          logger.report_nothing_to_generate
          return
        end
        logger.report_startup(source)
        mkdir_p(output) #unless File.directory?(output)
        Dir.chdir(output) do
          actionlist.each do |action, src, dest|
            atime = Time.now
            result, fulldest = *send(action, src, dest)
            logger.report_create(relative_to_output(dest), result, atime)
            #logger.report_create(dest, result, atime)
          end
        end
        logger.report_complete
        logger.report_fixes #if plugin.newproject? #&& project.new?
      end

    private

      # Prepares the manifest for operation. This method
      # passes the given manifest through a set of filters,
      # such as sorting and querying the user about duplicates,
      # finally arriving at a finalized manifest ready for
      # processing.
      #
      def manifest_prepare(manifest)
        manifest = manifest_glob(manifest)
        #manifest = manifest_dest(manifest)
        manifest = manifest_sort(manifest)
        #manifest.each do |s, d|
        #  puts "%40s %40s" % [s, d]
        #end
        manifest = manifest_copy(manifest)
        manifest = manifest_safe(manifest)

        check_manifest(manifest)  # TODO: should this come before or after prompt?
        check_overwrite(manifest)

        return manifest
      end

      #
      def manifest_glob(manifest)
        allfiles = {}
        dotpaths = ['.', '..']
        manifest.each do |match, into, opts|
          from = opts[:cd] || '.'
          srcs = []
          Dir.chdir(source + from) do
            srcs = Dir.glob(match, File::FNM_DOTMATCH)
            srcs = srcs.reject{ |d| File.basename(d) =~ /^[.]{1,2}$/ }
          end
          srcs = filter(srcs)
          srcs.each do |src|
            case into
            when /\/$/
              dest = File.join(into, File.basename(src))
            when '.'
              dest = src
            else
              dest = into
            end
            allfiles[from == '.' ? src : File.join(from, src)] = template_to_filename(dest) #dest
          end
        end
        allfiles.map do |f, t| 
          #if File.directory?(t)
          #  [f, File.join(t, File.basename(f))]
          #else
            [f,t]
          #end
        end
      end

=begin
      # Complete destination.
      def manifest_dest(manifest)
        manifest.collect do |src, dest|
          case dest
          when nil
            dest = src
          when '/.'
            dest = src
          when /\/[.]$/
            dest = File.join(dest.chomp('/.'), src)
          when '/', '.'
            dest = File.basename(src)
          when /\/$/
            #dest = File.join(dest, template_to_filename(File.basename(src)))
            dest = File.join(dest, File.basename(src))
          #else
          #  dest = dest
          end
          dest = template_to_filename(dest)
          [src, dest]
        end
      end
=end

      # Sort the manifest, directory before files and
      # in alphabetical order.
      def manifest_sort(manifest)
        dirs, files = *manifest.partition{ |src, dest| (source + src).directory? }
        expanded = dirs.sort + files.sort
      end

      ### Add copy action.
      def manifest_copy(manifest)
        manifest.collect do |src, dest|
          [:copy, src, dest]
        end
      end

      # Convert a template pathname into a destination pathname.
      # This allows for substitution in the pathnames themselves
      # by using '__name__' notation.
      #
      def template_to_filename(template)
        name = template.dup #chomp('.erb')
        name = name.gsub(/__(.*?)__/) do |md|
          metadata.send($1)
        end
        #if md =~ /^(.*?)[-]$/
        #  name = metadata[md[1]] || plugin.metadata(md[1]) || name
        #end
        name
      end

      # Filter out special files/directories.
      #
      def filter(paths)
        plugin.filter.each do |re|
          paths = paths.reject{ |pn| re =~ pn.to_s }
        end
        paths
      end

      # If in prompt mode, returns a manifest filtered of overwrites
      # as selected by the end user. If in skip mode, mark duplicates to
      # skipped. If not in prompt or skip mode, simply return the 
      # current manifest.
      #
      def manifest_safe(manifest)
        return manifest unless (prompt? or skip?)
        return manifest if manifest.empty?
        safe = []
        dups = []
        manifest.each do |action, tname, fname|
          dups << [action, tname, fname, (output + fname).file?]
        end
        puts "Select (y/n) which files to overwrite:\n" if prompt? unless quiet?
        dups.each do |action, tname, fname, check|
          if check
            if skip?
              safe << [:skip, tname, fname]
            else
              f = relative_to_output(fname)
              case ans = ask("      #{f}? ").downcase.strip
              when 'y', 'yes'
                safe << [action, tname, fname]
              else
                safe << [:skip, tname, fname]
              end
            end
          else
            safe << [action, tname, fname]
          end
        end
        puts
        return safe
      end

      # Check for any overwrites. If generator allows overwrites
      # this will be skipped, otherewise an error will be raised.
      #
      # TODO: Make this a manifest filter with check for "identical" files?
      def check_overwrite(manifest)
        return if force?
        return if prompt?
        return if skip?
        #return if plugin.overwrite?  # TODO: not so sure overwirte? option is a good idea.

        if plugin.newproject? && !output.glob('**/*').empty? # FIXME?
          abort "New project isn't empty. Use --force, --skip or --prompt."
        end

        clobbers = []
        manifest.each do |action, tname, fname|
          tpath = source + tname
          fpath = output + fname
          if fpath.file? #fpath.exist?
            clobbers << relative_to_output(fname)
          end
        end

        if !clobbers.empty?
          puts "    " + clobbers.join("\n    ")
          abort "These files would be overwritten. Use --force, --skip or --prompt."  # TODO: implement --skip
        end
      end

      # Check for any clashing generations, ie. a directory that
      # will overwrite a file or a file that will overwrite a
      # directory. This will raise an error if any of these
      # conditions are found, unless force? is set to true.
      #
      def check_manifest(manifest)
        #return if force?
        manifest.each do |action, tname, fname|
          tpath = source + tname
          fpath = output + fname
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

      #
      def skip(src, dest)
        return 'skip', dest
      end

      # Access to FileUtils
      def fu
        trial? ? FileUtils::DryRun : FileUtils
      end

      #
      def cp(src, dest)
        if trial?
          s = relative_to_source(src)
          d = relative_to_output(dest)
          puts "cp #{s} #{d}"
        else
          fu.cp(src, dest)
        end
      end

      #
      def mkdir_p(dir)
        if trial?
          d = relative_to_output(dir)
          puts "mkdir_p #{d}"
        else
          fu.mkdir_p(dir)
        end
      end

      # Write file.
      def write(file, text)
        if trial?
          f = relative_to_output(file)
          puts "write #{f}"
        else
          File.open(file, 'w'){ |f| f << text }
        end
      end

      #
      def rm(dest)
        if File.directory?(dest)
          if trial?
            d = relative_to_output(dest)
            puts "rmdir #{d}"
          else
            fu.rmdir(dest)
          end
        else
          if trial?
            d = relative_to_output(dest)
            puts "rm #{d}"
          else
            fu.rm(dest)
          end
        end
      end

      #
      def relative_to_source(src)
        Pathname.new(src).relative_path_from(source)
      end

      #
      def relative_to_output(dest)
        if dest =~ /^\//
          Pathname.new(dest).relative_path_from(output)
        else
          dest
        end
      end

    end

  end

end#module Sow

