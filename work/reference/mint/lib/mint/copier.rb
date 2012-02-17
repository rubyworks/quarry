module Mint

  #require 'rbconfig'
  require 'fileutils'
  require 'digest/md5'

  #def self.paths
  #  (ENV['MINT_PATH'] || []) + [datadir]
  #end

  # TODO Better way to support RubyGems and Rolls?
  #def self.datadir
  #  dir = File.expand_path("#{File.dirname(__FILE__)}/../../../data/mint")
  #  if File.directory?(dir)
  #    dir
  #  else
  #    File.join(File.join(Config::CONFIG['datadir'], 'mint'))
  #  end
  #end

  # Copier provides a factility for
  # performing interactive, managed copies.
  class Copier

    IGNORE = ['.', '..']

    ## Look for source file(s) in system locations?
    #attr_accessor :system

    # Source paths to copy. This can be a glob or an array of globs.
    attr_accessor :source

    # Directory (or a file, if copying one file) in which to store copied source.
    attr_accessor :destination

    # Just pretend to do the commit action.
    attr_accessor :pretend

    # Force provided an extra "dangerous" option of "(W)rite all".
    attr_accessor :force

    # Automatically skip all overwrites.
    attr_accessor :skip

    # Stores actions to be performed upon commit.
    attr_reader :actions

    # New copier.
    def initialize(source, destination, options=nil)
      @source     = [source].flatten
      @destination = destination

      @actions     = []

      options.each do |k,v|
        send("#{k}=",v)
      end
    end

    #def system?  ; @system  ; end

    def pretend? ; @pretend ; end
    def force?   ; @force   ; end
    def skip?    ; @skip    ; end

    # Files to copy.

    def copies
      #if system?
      #  system_lookup
      #else
        common_lookup
      #end
    end

    # Look up file in system locations.
    #def system_lookup
    #  copies = []
    #  Mint.paths.each do |path|
    #    source.each do |src|
    #      jpath = File.join(path, src)
    #      files = Dir.glob(jpath)
    #      files.each do |file|
    #        file = file.sub(path+'/','')
    #        copies << [path, file]
    #      end
    #    end
    #  end
    #  copies
    #end

    # Non-system lookup.
    def common_lookup
      copies = []
      source.each do |src|
        if i = src.index(/[*?]/)
          dir = src[0...i]
        else
          dir = File.dirname(src) + '/'
        end
        files = Dir.glob(src) #File.join(path, src))
        files.each do |file|
          #file = file.sub(path+'/','')
          file = file.sub(dir,'')
          copies << [dir, file]
        end
#           unless files.empty?
#             copies << [nil, files]
#           end
      end
      copies
    end

    # Copy files.
    def copy
      copies = copies()
      raise ArgumentError, 'nothing to copy' if copies.empty?
      #puts "KEY: (d)iff (r)eplace (s)kip (a)ll (q)uit"  # need to show?

      copies.each do |dir, file|
        path = dir ? File.join(dir, file) : file
        if File.file?(path)
          copy_file(dir, file)
        elsif File.directory?(path)
          base = File.basename(path)
          dirs, files = *partition(path)
          # make empty directories
          dirs.each do |d|
            #if File.directory?(File.join(destination,d))
            if File.directory?(File.join(destination,base,d))
              skip_dir(d)
            else
              #pth = File.join(path,d)
              pth = File.join(path,base,d)
              entries = Dir.entries(pth) - IGNORE
              make_dir(path, d) if entries.empty?
            end
          end
          # copy files in directories
          files.each do |f|
            copy_file(path, f, base) #f)
          end
        else
          raise ArgumentError, "unsupported file object -- #{path}"
        end
      end
      commit
    end

  private

    # Partition a directory's content between dirs and files.
    def partition(directory)
      dirs, files  = [], []
      chdir(directory) do
        paths = Dir.glob('**/*')
        dirs, files = *paths.partition do |f|
          File.directory?(f)
        end
      end
      return dirs, files
    end

    # Make a directory.
    def make_dir(source, dir)
      dst = File.join(destination, dir)
      if File.file?(dst)
        puts "Directory to replace file..."
        action = query(source, dir) || 'skip'
      else
        action = 'make'
      end
      @actions << [action, dst]
      action_print(action, dst + '/')
    end

    # Copy a file.
    def copy_file(source, file, base=nil)
      src = File.join(source, file)
      if base
        dst = File.join(destination, base, file)
      else
        dst = File.join(destination, file)
      end
      action = 'skip'
      if File.directory?(dst)
        puts "File to replace directory..."
        action = query(source, file)
      elsif File.file?(dst)
        unless identical?(src, dst)
          action = query(source, file)
        end
      else
        action = 'copy'
      end

      @actions << [action, [src, dst]]

      #if action == 'copy' or action == 'replace'
      #  rm_r(dst) if File.directory?(dst)
      #  cp(src, dst)
      #end

      action_print(action, dst) #, file)
    end

    # Skip directory.
    def skip_dir(dst)
      @actions << ['skip', dst]
      action_print('skip', dst + '/')
    end

    # Skip file.
    #
    # TODO: Why is this never called?

    def skip_file(src, dst)
      @actions << ['skip', [src, dst]]
      action_print('skip', dst)
    end

    # Show diff of files.
    def diff(source, file)
      src = File.join(source, file)
      dst = File.join(destination, file)
      dout = diff_files(src, dst)
      puts dout unless dout.empty?
    end

    # Show diff of two files.
    def diff_files(file1, file2)
      `diff #{file1} #{file2}`.strip
    end

    BUF_SIZE = 1024*1024

    # Are two files identical? This compares size and then checksum.
    def identical?(file1, file2)
      size(file1) == size(file2) && md5(file1) == md5(file2)
    end

    #
    def size(file)
      File.size(file) 
    end

    # Return an md5 checkum. If a directory is given, will
    # return a nested array of md5 checksums for all entries.
    def md5(path)
      if File.directory?(path)
        md5_list = []
        crt_dir = Dir.new(path)
        crt_dir.each do |file_name|
          next if file_name == '.' || file_name == '..'
          md5_list << md5("#{crt_dir.path}#{file_name}")
        end
        md5_list
      else
        hasher = Digest::MD5.new
        open(path, "r") do |io|
          counter = 0
          while (!io.eof)
            readBuf = io.readpartial(BUF_SIZE)
            counter+=1
            #putc '.' if ((counter+=1) % 3 == 0)
            hasher.update(readBuf)
          end
        end
        return hasher.hexdigest
      end
    end

    # Query about file.
    def query(source, file)
      return 'skip' if safe?
      return 'replace' if force?
      action = nil
      #msg = "#{file} -- (d)iff (r)eplace (s)kip (a)ll (q)uit?"
      msg = "       ? #{file} "
      until action
        ans = ask(msg).strip[0,1]
        case ans
        when 'd', 'D'
          diff(source, file)
        when 'r', 'R'
          action = 'replace'
        when 's', 'S'
          action = 'skip'
        when 'a', 'A'
          @safe = true
          action = 'skip'
        when 'q', 'Q'
          exit 0
        end
      end
      return action
    end

    #
    def safe?
      @safe
    end

    # Action print.
    def action_print(action, file)
      file = file.sub(/^[.]\//,'')
      action = (' ' * (8 - action.size)) + action
      puts "#{action} #{file}"
    end

    # Perform actions.
    def commit!
      actions.each do |action, path|
        case action
        when 'make'
          #rm(path) if File.directory?(path)
          mkdir_p(path)
        when 'copy'
          src, dst = *path
          rm_r(dst) if File.directory?(dst)
          mkdir_p(File.dirname(dst))
          cp(src, dst)
        when 'replace'
          src, dst = *path
          rm_r(dst) if File.directory?(dst)
          #mkdir_p(File.dirname(dst))
          cp(src, dst)
        else # skip
          # do nothing
        end
      end
    end

    # Confirm commit.
    def commit
      ans = ask("Commit y/N?")
      case ans.downcase
      when 'y', 'yes'
        commit!
      end
    end

    # Get user input.
    def ask(msg)
      print "#{msg} "
      until inp = $stdin.gets ; sleep 1 ; end
      inp.chomp
    end

    # Delegation to FileUtils.
    def fu
      @pretend ? FileUtils::DryRun : FileUtils
    end

    def chdir(*a,&b)   ; fu.chdir(*a,&b)   ; end
    def rm(*a,&b)      ; fu.rm(*a,&b)      ; end
    def rm_r(*a,&b)    ; fu.rm_r(*a,&b)    ; end
    def cp(*a,&b)      ; fu.cp(*a,&b)      ; end
    def cp_r(*a,&b)    ; fu.cp_r(*a,&b)    ; end
    def mkdir(*a,&b)   ; fu.mkdir(*a,&b)   ; end
    def mkdir_p(*a,&b) ; fu.mkdir_p(*a,&b) ; end

  end

end

