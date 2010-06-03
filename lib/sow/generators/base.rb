require 'facets/pathname'
require 'sow/core_ext'
require 'sow/context'

module Sow

  module Generators

    # Base Class for the generators. This provides the
    # backbone of Sow's operations. Essentially a plugin
    # provides a copylist to the generator, which cleans
    # it up and uses it for it's specific task,
    # eg. create, update or delete.
    #
    class Base

      attr :session
      #attr :location
      attr :copylist

      attr :context
      attr :logger

      def initialize(session, copylist)

        if session.debug?
          puts "\n[copylist]"
          copylist.each do |loc, tname, fname, opts|
            puts "#{loc.to_s.inspect} #{tname.inspect} #{fname.inspect} #{opts.inspect}"
          end
        end

        @session   = session
        #@location  = location
        @copylist  = copylist

        @logger    = Logger.new(self)
        @context   = Context.new(metadata)
      end

      #
      def metadata
        session.metadata
      end

      # Where to find plugin files.
      #alias_method :source, :location

      # TODO: rename to 'destination'
      def output
        @output ||= (
          #if session.create? && plugin.name #scaffold && session.scaffold?
          #  session.output + plugin.name
          #else
            session.destination
          #end
        )
      end

      #
      def arguments
        session.arguments
      end

      def trial?  ; session.trial?  ; end
      def debug?  ; session.debug?  ; end
      def quiet?  ; session.quiet?  ; end
      def force?  ; session.force?  ; end
      def prompt? ; session.prompt? ; end
      def skip?   ; session.skip?   ; end

      # Newuse of sow? In other words, is the destination empty?
      def newproject?
        session.new?
      end

      # Main command called to generate files.
      #
      def generate #(args, opts)
        actionlist = actionlist(copylist)

        if actionlist.empty?
          logger.report_nothing_to_generate
          return
        end

        source = '' # FIXME
        logger.report_startup(source, output)

        mkdir_p(output) unless File.directory?(output)

        backup(actionlist)

        Dir.chdir(output) do
          actionlist.each do |action, loc, src, dest, opts|
            atime = Time.now
            result, fulldest = *__send__(action, loc, src, dest, opts)
            logger.report_create(relative_to_output(dest), result, atime)
            #logger.report_create(dest, result, atime)
          end
        end

        logger.report_complete
        logger.report_fixes #if session.newproject?
      end

    private

      #
      def backup(actionlist)
        list = []
        actionlist.each do |action, loc, src, dest, opts|
          case action
          when 'copy'
            list << dest
          end
        end
        stamp = Time.now.strftime('%Y%m%d%H%M%S')
        base = session.destination + ".sow/undo/#{stamp}"
        list.each do |file|
          next unless File.file?(file)
          back = base + file.sub(Dir.pwd,'')
          back.parent.mkpath
          cp(file, back)
        end
      end

      # Processes with erb.
      def erb(file)
        context.erb(file)
        #metadata.erb(file)
      end

      #
      def mark; 'copy'; end

      def actionlist(list)
        list = actionlist_sort(list)
        list = actionlist_mark(list)
        list = actionlist_safe(list)
        list = actionlist_check(list)
        list
      end

      def actionlist_sort(list)
        list
      end

      # Add copy action.
      def actionlist_mark(list)
        list.map do |args|
          [mark, *args]
        end
      end

      # If in prompt mode, returns a list filtered of overwrites
      # as selected by the user. If in skip mode, mark duplicates to
      # skipped. If not in prompt or skip mode, simply return the 
      # current list.
      #
      def actionlist_safe(list)
        return list unless (prompt? or skip?)
        return list if list.empty?
        safe = []
        dups = []
        list.each do |action, loc, tname, fname, opts|
          dups << [action, loc, tname, fname, opts, (output + fname).file?]
        end
        puts "Select (y/n) which files to #{clobber_term}:\n" if prompt? unless quiet?
        dups.each do |action, loc, tname, fname, opts, check|
          if check
            if skip?
              safe << [:skip, loc, tname, fname, opts]
            else
              f = relative_to_output(fname)
              case ans = ask("      #{f}? ").downcase.strip
              when 'y', 'yes'
                safe << [action, loc, tname, fname, opts]
              else
                safe << [:skip, loc, tname, fname, opts]
              end
            end
          else
            safe << [action, loc, tname, fname, opts]
          end
        end
        puts
        return safe
      end

      #
      def actionlist_check(list)
        check_conflicts(list)  # TODO: should this come before or after prompt?
        check_overwrite(list)
        list
      end       

      # Check for any overwrites. If generator allows overwrites
      # this will be skipped, otherewise an error will be raised.
      #
      # TODO: Make this a list filter with check for "identical" files?
      def check_overwrite(list)
        return if force?
        return if prompt?
        return if skip?
        #return if session.overwrite?  # TODO: not so sure overwrite? option is a good idea.

        if newproject? && !output.glob('**/*').empty? # FIXME?
          abort "New project isn't empty. Use --force, --skip or --prompt."
        end

        clobbers = []
        list.each do |action, loc, tname, fname, opts|
          tpath = loc + tname
          fpath = output + fname
          if fpath.file? #fpath.exist?
            clobbers << relative_to_output(fname)
          end
        end

        # TODO: implement --skip
        if !clobbers.empty?
          puts "    " + clobbers.join("\n    ")
          abort "These files would be overwritten. Use --force, --skip or --prompt."
        end
      end

      # Check for any clashing generations, ie. a directory that
      # will overwrite a file or a file that will overwrite a
      # directory. This will raise an error if any of these
      # conditions are found, unless force? is set to true.
      #
      def check_conflicts(list)
        #return if force?
        list.each do |action, loc, tname, fname, opts|
          tpath = loc + tname
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
      def skip(loc, src, dest, opts)
        return 'skip', dest
      end

      # Access to FileUtils
      def fu
        trial? ? FileUtils::DryRun : FileUtils
      end

      #
      def cp(src, dest)
        if trial?
          s = src #relative_to_source(src)
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
          fu.mkdir_p(dir) unless File.directory?(dir)
        end
      end

      #
      def chmod(mode, file)
        if trial?
          f = relative_to_output(file)
          puts "chmod #{f} #{mode}"
        else
          fu.chmod(mode, file)
        end
      end

      # Write file.
      def write(file, text)
        if trial?
          f = relative_to_output(file)
          puts "write #{f}"
        else
          mkdir_p(File.dirname(file))
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

      # FIXME
      #def relative_to_source(src)
      #  Pathname.new(src).relative_path_from(source)
      #end

      #
      def relative_to_output(dest)
        if dest =~ /^\//
          Pathname.new(dest).relative_path_from(output)
        else
          dest
        end
      end

      #
      def inspect
        "#<#{self.class} @session=#{@session.inspect}>"
      end

    end

  end

end#module Sow

