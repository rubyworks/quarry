require 'sow/logger'
require 'sow/core_ext'

module Sow

  #
  class Copier

    attr :source
    attr :output
    attr :options
    attr :copylist
    attr :logger

    # output - destination directory
    #
    def initialize(source, output, options={})
      @source   = Pathname.new(source)
      @output   = Pathname.new(output)
      @options  = options.to_h

      @logger   = Logger.new(self)
      @copylist = initialize_copylist

      if debug?
        $stderr.puts "\n[copylist]"
        copylist.each do |file|
          $stderr.puts "#{file}"
        end
        $stderr.puts
      end
    end

    #
    def initialize_copylist
      copylist = []
      Dir.recurse(source.to_s) do |file|
        fname = file.sub(source.to_s+'/', '')
        copylist << fname
      end
      copylist = copylist.reject{ |fname| identical?(fname) }
      copylist
    end

    private :initialize_copylist

    #
    def identical?(fname)
      src = source + fname
      out = output + fname
      if src.directory?
        out.directory?
      else
        if out.exist?
          FileUtils.compare_file(src, out)
        else
          false
        end
      end
    end

    # New use of sow? In other words, is the destination empty?
    #def new_project?
    #  options.new?
    #end

    def debug? ; $DEBUG  ; end
    def trial? ; $DRYRUN ; end

    def quiet?  ; options[:quiet] ; end

    def write?  ; options[:mode] == :write  ; end
    def prompt? ; options[:mode] == :prompt ; end
    def skip?   ; options[:mode] == :skip   ; end

    def backup? ; options[:backup].nil? or options[:backup] ; end

    def managed?
      write? or skip? or prompt?
    end

    # Main command called to generate files.
    #
    def copy
      actionlist = actionlist(:copy, copylist)

      if actionlist.empty?
        logger.report_nothing_to_generate
        return
      end

      logger.report_startup(source, output)

      mkdir_p(output) unless File.directory?(output)

      backup(actionlist)

      Dir.chdir(output) do
        actionlist.each do |action, fname|
          atime = Time.now
          how = __send__("#{action}_item", Pathname.new(fname))
          logger.report_create(fname, how, atime)
          #logger.report_create(dest, result, atime)
        end
        logger.report_complete
        logger.report_fixes(actionlist.map{|a,f|f})
      end
    end

    #
    def inspect
      "#<#{self.class} @options=#{@options.inspect}>"
    end

  private

    #
    BACKUP_DIRECTORY = '.sow/undo'

    #
    def backup(actionlist)
      list = []
      actionlist.each do |action, fname|
        case action.to_sym
        when :copy
          list << fname
        end
      end
      stamp = Time.now.strftime('%Y%m%d%H%M%S')
      base = output + File.join(BACKUP_DIRECTORY, stamp)
      list.each do |fname|
        dest = output + fname
        next unless dest.file?
        back = base + fname #.sub(Dir.pwd,'')
        back.parent.mkpath
        cp(fname, back)
      end
    end

    #
    def actionlist(action, list)
      list = actionlist_sort(action, list)
      list = actionlist_mark(action, list)
      list = actionlist_safe(action, list)
      list = actionlist_check(action, list)
      list
    end

    # TODO: need to sort?
    def actionlist_sort(action, list)
      list
    end

    # Add copy action.
    def actionlist_mark(action, list)
      list.map{ |fname| [action, fname] }
    end

    # If in prompt mode, returns a list filtered of overwrites
    # as selected by the user. If in skip mode, mark duplicates to
    # skipped. If not in prompt or skip mode, simply return the 
    # current list.
    #
    # TODO: Improve input/ouput thru logger.
    def actionlist_safe(action, list)
      return list unless (prompt? or skip?)
      return list if list.empty?
      safe = []
      dups = []
      list.each do |action, fname|
        dups << [action, fname, (output + fname).file?]
      end
      logger.report "Select (y/n) which files to overwrite:\n" if prompt?
      dups.each do |action, fname, check|
        if check
          if skip?
            safe << [:skip, fname]
          else
            case ans = ask("      #{fname}? ").downcase.strip
            when 'y', 'yes'
              safe << [action, fname]
            else
              safe << [:skip, fname]
            end
          end
        else
          safe << [action, fname]
        end
      end
      logger.newline
      return safe
    end

    #
    def actionlist_check(action, list)
      case action
      when :copy
        check_conflicts(list)  # TODO: should this come before or after prompt?
        check_overwrite(list)
        list
      when :delete
        list
      end
    end       

    # Check for any overwrites. If generator allows overwrites
    # this will be skipped, otherewise an error will be raised.
    #
    # TODO: Make this a list filter with check for "identical" files?
    def check_overwrite(list)
      return if write?
      return if prompt?
      return if skip?
      #if newproject? && !output.glob('**/*').empty? # FIXME?
      #  abort "New project isn't empty. Use --force, --skip or --prompt."
      #end
      clobbers = []
      list.each do |action, fname|
        tpath = source + fname
        fpath = output + fname
        if fpath.file? #fpath.exist?
          clobbers << fname
        end
      end
      # TODO: implement --skip
      if !clobbers.empty?
        puts "    " + clobbers.join("\n    ")
        raise "These files would be overwritten. Use --write, --skip or --prompt."
      end
    end

    # Check for any clashing generations, ie. a directory that
    # will overwrite a file or a file that will overwrite a
    # directory. This will raise an error if any of these
    # conditions are found, unless write? is set to true.
    #
    def check_conflicts(list)
      #return if write?
      list.each do |action, fname|
        tpath = source + fname
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

    # I T E M  F U N C T I O N S

    #
    def copy_item(fname)
      src = source + fname
      if src.directory?
        copy_dir(fname)
      else
        copy_doc(fname)
      end
    end

    #
    def copy_dir(fname)
      dest = fname #output + fname
      if dest.exist?
        how = 'same'
      else
        mkdir_p(dest)
        how = 'create'
      end
      return how
    end

    #
    def copy_doc(fname)
      src  = source + fname
      dest = fname #output + fname

      how = dest.exist? ? 'update' : 'create'
      cp(src, dest)
      return how
    end

    # Delete file.
    def delete_item(fname)
      dest = fname #output + fname
      if dest.exist?
        how = 'delete'
        begin
          rm(dest)
        rescue Errno::ENOTEMPTY
          how = 'skip'
        end
      else
        how = 'missing'
      end
      return how
    end

    #
    def skip_item(fname)
      dest = fname #output + fname
      return 'skip'
    end

    # Access to FileUtils
    def fu
      trial? ? FileUtils::DryRun : FileUtils
    end

    #
    def cp(src, dest)
      src, dest = src.to_s, dest.to_s
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
      dir = dir.to_s
      if trial?
        d = relative_to_output(dir)
        puts "mkdir_p #{d}"
      else
        fu.mkdir_p(dir) unless File.directory?(dir)
      end
    end

    #
    def chmod(mode, file)
      file = file.to_s
      if trial?
        f = relative_to_output(file)
        puts "chmod #{f} #{mode}"
      else
        fu.chmod(mode, file)
      end
    end

    # Write file.
    def write(file, text)
      file = file.to_s
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
      dest = dest.to_s
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

  end

end
