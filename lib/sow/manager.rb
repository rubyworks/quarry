require 'uri'
require 'finder'
require 'sow/copier'

module Sow

  SEED_MARK = ".seed"

  # The Manager class manages and locates sow seeds.
  #
  class Manager

    #
    # Where to install seed banks. This sow configuration directory defaults
    # to '~/.sow', but it can be changes with the `$SOW_BANK` environment
    # variable. For example, if you want to use XDG base directory standard,
    # you can set that with:
    #
    #   export SOW_BANK="$XDG_CONFIG_HOME/sow"
    #
    SOW_BANK = ENV['SOW_BANK'] || File.expand_path('~/.sow')

    #
    # Where to store personal seeds. This default to `$SOW_BANK/silo`.
    # 
    #SOW_SILO = ENV['SOW_SILO'] || SOW_BANK + '/silo'

    #
    # Full path to sow banks.
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
    # Full path to directory in which sow stores seed banks.
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
    # Find a seed given it's name, or first unique portion of it's name.
    # 
    def find_seed(match)
      hits = match_seed(match)
      if hits.size == 0
        raise "No matching seeds."
      end
      if hits.size > 1
        raise "More than one matching seed:\n  " + hits.map{|name, dir|name}.join("\n  ")
      end
      seed = hits.first
      seed
    end

    #
    #
    #
    def fetch_seed(uri, options={})
      clone(uri, options)
    end

    #
    # Match seed.
    #
    def match_seed(match)
      hits = seeds.select do |seed|
        match == seed.name
      end
      if hits.size == 0
        hits = seeds.select do |seed|
          /^#{match}/ =~ seed.name
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
    # Sorted list of seed names.
    #
    # @return [Array] Sorted seed names.
    #
    def seed_list
      seeds.map{ |seed| seed.name }.sort_by{ |a|
        i = a.index('@')
        i ? [a[i+1..-1], a] : [a, a]
      }
    end

    #
    # Alias for `#seed_list`.
    #
    alias_method :list, :seed_list

    #
    # Cached list of seeds.
    #
    def seeds
      @seeds ||= collect_seeds
    end

    #
    # Iterates over all banks and collects a list of Seed objects.
    #
    # @return [Array<Seed>] List of seeds.
    #
    def collect_seeds
      list = []

      # project directory  (TODO: locate project root ?)
      dirs = work_folder.glob("sow/*/")
      dirs = dirs.map{ |d| d.expand_path }  # clears off the trialing '/'
      dirs.each do |dir|
        seed = Seed.new(dir, :type=>'work')
        list << seed
      end

      # personal silo
      #dirs = silo_folder.glob("*")
      #dirs = dirs.map{ |d| d.parent }
      #dirs.each do |dir|
      #  seed = Seed.new(dir, :type=>'silo')
      #  list << seed
      #end

      # seed bank
      dirs = bank_folder.glob("*/")
      dirs = dirs.map{ |d| d.expand_path }  # clears off the trialing '/'
      dirs.each do |dir|
        seed = Seed.new(dir, :type=>'bank')
        list << seed
      end

      # seed plugins
      dirs = []
      dirs.concat ::Find.data_path("sow/**/#{SEED_MARK}")
      dirs = dirs.uniq.map{ |d| File.dirname(d) }
      dirs.each do |dir|
        seed = Seed.new(dir, :type=>'plugin')
        list << seed
      end

      list
    end

    #
    # Lookup seed and return the contents of it's README file.
    # If it does not have a README file that it will return a
    # message cveying as much. If the seed is not found it 
    # raise an error.
    #
    def help(name)
      seed = find_seed(name)
      if seed
        seed.help
      else
        raise "No matching seed."
      end
    end

    # TODO: Use SCM gem in #clone and #update.

    #
    # Clone a seed.
    #
    def clone(uri, options={})
      name  = options[:name] || uri_to_name(uri)
      dir   = bank_folder
      out   = dir + name

      if File.exist?(out)
        $stderr.puts "seed already exists -- #{name}"
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
    # Update seed bank(s). Since seed banks are usually version controlled
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
    # Remove a seed bank.
    #
    def uninstall(name)
      bank = find_bank(name)
      shell.rm_rf(bank.to_s) if bank
    end

    #
    # Find a seed by name, or closest prefix match.
    #
#    def find_seed(name)
#      seeds = bank_folder.glob(name)
#      seeds = bank_folder.glob("#{name}*") if seeds.empty?
#      raise "no such seed" if seeds.size < 1
#      raise "not a unique seed reference" if seeds.size > 1
#      seed = seeds.first
#      seed ? Pathname.new(seed) : nil
#    end

#    #
#    # Return a list of seed names.
#    #
#    # @return [Array] List of bank names.
#    #
#    def banks(match=nil)
#      bank_folder.glob("#{match}*/").map{ |s| s.basename.to_s.chomp('/') }.sort
#    end

    #
    # Save contents of source folder to the named seed in one's personal
    # silo collection.
    #
    def save(name, src=nil)
      raise "no seed name given" unless name
      src = src || Dir.pwd
      dir = silo_folder + "#{name}"
      copier = Copier.new(src, dir, :backup=>false)
      copier.copy
      sowfile = dir + '.sow/Sowfile'
      if !sowfile.exist?
        File.open(sowfile, 'w'){ |f| f << 'copy all' }
      end
      dir
    end

    #
    # Remove a seed.
    #
    # @todo Prompt for confirmation unless --force flag it used.
    #
    def remove(name)
      dir = find_seed(name)
      # ask("Are you sure you want to remover #{name}? [Yn]")
      shell.rm_rf(dir) if dir
    end

    ##
    ## Find a silo seed by name, or closest prefix match.
    ##
    #def find_silo_seed(name)
    #  raise "no seed name given" unless name
    #  seeds = silo_folder.glob(name)
    #  seeds = silo_folder.glob("#{name}*") if seeds.empty?
    #  raise "no such silo seed" if seeds.size < 1
    #  raise "not a unique silo seed reference" if seeds.size > 1
    #  seed = seeds.first
    #  seed ? Pathname.new(seed) : nil
    #end

    ##
    ## Returns a list of silo seed names.
    ##
    ## @return [Array] List of silo seed names.
    ##
    #def silos
    #  silo_folder.glob('*').map{ |s| s.basename.to_s }
    #end

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

  private

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

end #module Sow

