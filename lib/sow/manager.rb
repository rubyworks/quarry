require 'uri'
require 'plugin'
require 'sow/copier'

module Sow

  # The Manager class manages and locates sow seeds.
  #
  class Manager

    # Home configuration directory.
    HOME_CONFIG = ENV['XDG_CONFIG_HOME'] || File.expand_path('~/.config')

    # User configuration directory for sow.
    SOW_CONFIG  = ENV['SOW_HOME'] || HOME_CONFIG + '/sow'

    # User seed location.
    #BANK_FOLDER = ENV['SOW_BANK'] || HOME_CONFIG + '/sow/seeds'

    # Where to store personal seeds.
    #SAVE_FOLDER = ENV['SOW_SAVE'] || HOME_CONFIG + '/sow/seeds/personal'

    #
    def self.bank_folder
      @bank_folder ||= (
        default = SOW_CONFIG + '/bank'
        folder  = read_setting('bank_folder', default)
        Pathname.new(File.expand_path(folder))
      )
    end

    #
    def self.silo_folder
      @silo_folder ||= (
        default = SOW_CONFIG + '/silo'
        folder  = read_setting('silo_folder', default)
        Pathname.new(File.expand_path(folder))
      )
    end

    #
    def self.read_setting(name, default=nil)
      file = SOW_CONFIG + "/settings/#{name}"
      if File.exist?(file)
        File.read(file).strip
      else
        default
      end
    end

    #
    def initialize(options=nil)
      @options = (options || OpenStruct.new).to_ostruct
    end

    #
    def options
      @options
    end

    #
    def bank_folder
      @bank_folder ||= self.class.bank_folder
    end

    #
    def silo_folder
      @silo_folder ||= self.class.silo_folder
    end

    # TODO: look for exact match first
    def find_seed(match)
      loc = nil
      seed_map.each do |name, dir|
        loc = dir if /^#{match}\./ =~ name
      end
      seed_map.each do |name, dir|
        loc = dir if match == name
      end
      loc = Pathname.new(loc) if loc
      loc
    end

    #
    def trial?
      $DRYRUN
    end

    #
    def seeds
      @seeds ||= seed_map.map{ |a| a.first }
    end

    alias_method :list, :seeds

    # Returns an Array of [seed name, seed directory] pairs.
    def seed_map
      list = []

      # personal silo
      dirs = silo_folder.glob('**/.sow/Sowfile')
      dirs = dirs.map{ |d| d.parent.parent }
      dirs.each do |d|
        n = d.sub(silo_folder.to_s,'')
        k = path_to_name(n)
        list << [k, d]
      end

      # seed bank
      dirs = bank_folder.glob('**/.sow/Sowfile')
      dirs = dirs.map{ |d| d.parent.parent }
      dirs.each do |d|
        n = d.sub(bank_folder.to_s,'')
        k = path_to_name(n)
        list << [k, d]
      end

      # seed plugins
      dirs = ::Plugin.find(File.join('sow', '**/.sow/Sowfile'))
      dirs = dirs.map{ |d| File.dirname(File.dirname(d)) }
      dirs.each do |d|
        n = d[d.rindex('/sow/')+5..-1]
        k = path_to_name(n)
        list << [k, d]
      end

      list
    end

    # Lookup seed and and return the contents of it's
    # README file. If it does not have a README file
    # it will return 'No README'.
    def readme(name)
      dir = find_seed(name)
      if dir
        readme = File.join(dir, 'README')
        return File.read(readme) if File.exist?(readme)
      end
      return 'No README' unless dir
    end

    # Install a seed bank.
    def install(uri, alt=nil)
      alt  = alt || uri_to_name(uri)
      dir  = bank_folder
      out  = dir + alt
      name = File.basename(uri).chomp(File.extname(uri))
      if File.exist?(out + name)
        $stderr.puts "#{out + name} already exists"
        return # update ?
      end
      case uri
      when /^git\:/, /\.git$/
        cmd = "git clone #{uri} #{name}"
      when /^svn\:/
        cmd = "svn checkout clone #{uri} #{name}"
      else # local path
        cmd = "ln -s #{uri} #{out}"
      end
      if trial?
        $stderr.puts("  mkdir -p #{out}")
        $stderr.puts("  cd #{out}")
        $stderr.puts("  #{cmd}")
      else
        FileUtils.mkdir_p(out)
        `cd #{out}; #{cmd}`
      end
    end

    #
    def path_to_name(path)
      div  = path.split('/') # File::SEPARATOR ?
      name = div.reverse.join('.').chomp('.')
      if md = /default\./.match(name)
        name = md.post_match
      end
      name
    end

    # Update seed bank(s).
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

    # Remove installed seed bank.
    def uninstall(name)
      bank = find_bank(name)
      shell.rm_rf(bank.to_s) if bank
    end

    # Find a seed bank by name, or closest prefix match.
    def find_bank(name)
      banks = bank_folder.glob(name)
      banks = bank_folder.glob("#{name}*") if banks.empty?
      raise "no such seed bank" if banks.size < 1
      raise "not a unique seed bank reference" if banks.size > 1
      bank = banks.first
      bank ? Pathname.new(bank) : nil
    end

    # Return an Array of banks.
    def banks(match=nil)
      bank_folder.glob("#{match}*").map{ |s| s.basename.to_s }.sort
    end

    # Save a silo seed.
    def save(name, src=nil)
      raise "no seed name given" unless name
      src = src || Dir.pwd
      dir = silo_folder + "#{name}/template"
      copier = Copier.new(src, dir, :backup=>false)
      copier.copy
      sowfile = dir.parent + 'Sowfile'
      if !sowfile.exist?
        File.open(sowfile, 'w'){ |f| f << 'copy all' }
      end
      dir
    end

    # Remove a silo seed.
    def remove(name)
      dir = find_silo_seed(name)
      shell.rm_rf(dir) if dir
    end

    # Find a silo seed by name, or closest prefix match.
    def find_silo_seed(name)
      raise "no seed name given" unless name
      seeds = silo_folder.glob(name)
      seeds = silo_folder.glob("#{name}*") if seeds.empty?
      raise "no such silo seed" if seeds.size < 1
      raise "not a unique silo seed reference" if seeds.size > 1
      seed = seeds.first
      seed ? Pathname.new(seed) : nil
    end

    # Returns an Array of silo seed names.
    def silos
      silo_folder.glob('*').map{ |s| s.basename.to_s }
    end

    # Convert an URI into a suitable directory name.
    def uri_to_name(uri)
      uri = URI.parse(uri)
      path = uri.path
      path = path.chomp(File.extname(path))
      path = path.split('/').reverse.join('.')
      path + uri.host
    end

    ; ; ; private ; ; ;

    # Interface to FileUtils or FileUtils::DryRun.
    def shell
      $DRYRUN ? FileUtils::DryRun : FileUtils
    end

  end

end #module Sow

