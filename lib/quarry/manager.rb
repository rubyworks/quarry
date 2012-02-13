require 'uri'
require 'finder'
require 'quarry/copier'

module Quarry

  # The Manager class manages and locates quarry ores.
  #
  class Manager

    #
    # Full path to quarry banks.
    #
    def self.bank_folder
      @bank_folder ||= (
        Pathname.new(File.expand_path(SOW_BANK))
      )
    end

    ##
    ## Full path to personal bank.
    ##
    ##def self.silo_folder
    #  @silo_folder ||= (
    #    Pathname.new(File.expand_path(SOW_SILO))
    #  )
    #end

    #
    #def self.read_setting(name, default=nil)
    #  file = SOW_CONFIG + "/settings/#{name}"
    #  if File.exist?(file)
    #    File.read(file).strip
    #  else
    #    default
    #  end
    #end

    #
    # Initialize new Manger instance.
    #
    def initialize(options={})
      @options    = options   # not in use presently, but just in case
      @namespaces = {}
    end

    #
    #
    #
    def options
      @options
    end

    # THINK: Should work_folder be a lookup of project root?

    #
    # Current working directory.
    #
    def work_folder
      @work_folder ||= Pathname.new(Dir.pwd) #self.class.bank_folder
    end

    #
    # Full path to directory in which quarry stores local ore.
    #
    def bank_folder
      @bank_folder ||= self.class.bank_folder
    end

    ##
    ## Full path to personal seee bank.
    ##
    #def silo_folder
    #  @silo_folder ||= self.class.silo_folder
    #end

    #
    # Find ore given it's name, or first unique portion of it's name.
    # 
    def find(match)
      hits = match(match)
      if hits.size == 0
        raise "No matching ore."
      end
      if hits.size > 1
        raise "More than one match:\n  " + hits.map{|name, dir| name}.join("\n  ")
      end
      ore = hits.first
      ore
    end

    #
    # Fetch ore from URL.
    #
    def fetch(uri, options={})
      clone(uri, options)
    end

    #
    # Match ore.
    #
    def match(match)
      hits = ores.select do |ore|
        match == ore.name
      end
      if hits.size == 0
        hits = ores.select do |ore|
          /^#{match}/ =~ ore.name
        end
      end
      return hits
    end

    #
    # Is this a trial run? This information comes from the global $DRYRUN variable.
    #
    def trial?
      $DRYRUN
    end

    #
    # Sorted list of ore names.
    #
    # @return [Array] Sorted ore names.
    #
    def list
      ores.map{ |ore| ore.name }.sort_by{ |a|
        i = a.index('@')
        i ? [a[i+1..-1], a] : [a, a]
      }
    end

    #
    # Cached list of ores.
    #
    def ores
      @ores ||= collect
    end

    #
    # Lookup ore and return the contents of it's README file.
    # If it does not have a README file that it will return a
    # message cveying as much. If the ore is not found it 
    # raise an error.
    #
    def help(name)
      ore = find(name)
      if ore
        ore.help
      else
        raise "No matching ore."
      end
    end

    # TODO: Use SCM gem in #clone and #update.

    #
    # Clone a ore.
    #
    def clone(uri, options={})
      name  = options[:name] || uri_to_name(uri)
      dir   = bank_folder
      out   = dir + name

      if File.exist?(out)
        $stderr.puts "ore already exists -- #{name}"
        return # update ?
      end

      case uri
      when /^git\:/, /\.git$/
        cmd = "git clone #{uri} #{name}"
      when /^svn\:/
        cmd = "svn checkout clone #{uri} #{name}"
      else
        if url?(uri)  # assume git
          cmd = "git clone #{uri} #{name}"          
        else  # local path
          cmd = "ln -s #{uri} #{name}"
        end
      end

      if trial?
        $stderr.puts("  mkdir -p #{dir}")
        $stderr.puts("  cd #{dir}")
        $stderr.puts("  #{cmd}")
      else
        FileUtils.mkdir_p(dir)
        `cd #{dir}; #{cmd}`
      end

      return name
    end

=begin
    #
    def path_to_name(path)
      div   = path.to_s.split('/') # File::SEPARATOR ?
      div.pop if div.last == 'default'
      #name  = div.pop
      #group = div.pop
      name = div.reverse.join('.').chomp('.')

      #if group
      #  name = "#{group}:#{name}"
      #  name.chomp!(".default")
      #end

      #if !ns.empty?
      #  name = "#{name}-#{ns}"
      #end

      return name, namespace
    end
=end

    #
    # Update ore bank(s). Since ore banks are usually version controlled
    # repositories, they may need to be updated from time to time.
    #
    def update(name=nil)
      if name
        paths = bank_folder.glob(name)
        paths = bank_folder.glob("#{name}*") if paths.empty?
      else
        paths = bank_folder.glob("*")
      end

      paths.each do |out|
        if (out + '.git').exist?
          cmd = "git pull" # origin master"
        elsif (out + '.svn').exist?
          cmd = "svn update"
        else
          cmd = nil
        end
        if cmd
          if trial?
            $stderr.puts("cd #{out}; #{cmd}")
          else
            Dir.chdir(out.to_s) do
              `#{cmd}`
            end
          end
        end
      end
    end

    #
    # Remove a ore bank.
    #
    def uninstall(name)
      bank = find_bank(name)
      shell.rm_rf(bank.to_s) if bank
    end

    #
    # Find a ore by name, or closest prefix match.
    #
#    def find_ore(name)
#      ores = bank_folder.glob(name)
#      ores = bank_folder.glob("#{name}*") if ores.empty?
#      raise "no such ore" if ores.size < 1
#      raise "not a unique ore reference" if ores.size > 1
#      ore = ores.first
#      ore ? Pathname.new(ore) : nil
#    end

#    #
#    # Return a list of ore names.
#    #
#    # @return [Array] List of bank names.
#    #
#    def banks(match=nil)
#      bank_folder.glob("#{match}*/").map{ |s| s.basename.to_s.chomp('/') }.sort
#    end

    #
    # Save contents of source folder to the named ore in one's personal
    # silo collection.
    #
    def save(name, src=nil)
      raise "no ore name given" unless name
      src = src || Dir.pwd
      dir = silo_folder + "#{name}"
      copier = Copier.new(src, dir, :backup=>false)
      copier.copy
      copyfile = dir + '.ore/copy.rb'
      if !copyfile.exist?
        File.open(copyfile, 'w'){ |f| f << 'copy all' }
      end
      dir
    end

    #
    # Remove a ore.
    #
    # @todo Prompt for confirmation unless --force flag it used.
    #
    def remove(name)
      dir = find_ore(name)
      # ask("Are you sure you want to remover #{name}? [Yn]")
      shell.rm_rf(dir) if dir
    end

    ##
    ## Find a silo ore by name, or closest prefix match.
    ##
    #def find_silo_ore(name)
    #  raise "no ore name given" unless name
    #  ores = silo_folder.glob(name)
    #  ores = silo_folder.glob("#{name}*") if ores.empty?
    #  raise "no such silo ore" if ores.size < 1
    #  raise "not a unique silo ore reference" if ores.size > 1
    #  ore = ores.first
    #  ore ? Pathname.new(ore) : nil
    #end

    ##
    ## Returns a list of silo ore names.
    ##
    ## @return [Array] List of silo ore names.
    ##
    #def silos
    #  silo_folder.glob('*').map{ |s| s.basename.to_s }
    #end

  private

    #
    # Iterates over all banks and collects a list of Mine objects.
    #
    # @return [Array<Mine>] List of ores.
    #
    def collect
      list = []

      # project directory  (TODO: locate project root ?)
      dirs = work_folder.glob("quarry/*/")
      dirs = dirs.map{ |d| d.expand_path }  # clears off the trialing '/'
      dirs.each do |dir|
        ore = Mine.new(dir, :type=>'work')
        list << ore
      end

      # personal silo
      #dirs = silo_folder.glob("*")
      #dirs = dirs.map{ |d| d.parent }
      #dirs.each do |dir|
      #  ore = Mine.new(dir, :type=>'silo')
      #  list << ore
      #end

      # ore bank
      dirs = bank_folder.glob("*/")
      dirs = dirs.map{ |d| d.expand_path }  # clears off the trialing '/'
      dirs.each do |dir|
        ore = Mine.new(dir, :type=>'bank')
        list << ore
      end

      # ore plugins
      dirs = []
      dirs.concat ::Find.data_path("quarry/**/#{SCAFFOLD_MARKER}")
      dirs = dirs.uniq.map{ |d| File.dirname(d) }
      dirs.each do |dir|
        ore = Mine.new(dir, :type=>'plugin')
        list << ore
      end

      list
    end

    #
    # Convert an URI into a suitable directory name for storing banks.
    #
    def uri_to_name(uri)
      uri = URI.parse(uri)
      path = uri.path
      path = path.chomp(File.extname(path))
      #File.join(uri.host,path).split('/').reverse.join('.')
      path.split('/').reverse.join('.')
    end

    #
    # Interface to FileUtils or FileUtils::DryRun.
    #
    def shell
      $DRYRUN ? FileUtils::DryRun : FileUtils
    end

    #
    #
    #
    def url?(uri)
      /\w+\:\/\// =~ uri
    end

  end

end #module Quarry

