require 'plugin'
require 'sow/copier'

module Sow

  # The Manager class manages and locates sow seeds.
  #
  class Manager

    # Home configuration directory.
    HOME_CONFIG = ENV['XDG_CONFIG_HOME'] || '~/.config'

    # User installed seeds location.
    BANKS = (
      str = ENV['SOW_BANK'] || HOME_CONFIG + '/sow/seeds'
      str.split(/[:;]/)
    )

    # TODO: Stores location of personal seed bank.
    CONFIG = Pathname.new(File.expand_path('~/.config/sow/config.yml'))

    #
    def self.banks
      BANKS.map{ |dir| Pathname.new(dir) }
    end

    #
    def initialize(options=nil)
      @options = options || OpenStruct.new

    end

    #
    attr :options

    #
    def config
      @config ||= (
        File.exist?(CONFIG) ? YAML.load(CONFIG) : {}
      )
    end

    #
    def banks
      @banks ||= self.class.banks
    end

    #
    def find_seed(match)
      loc = nil
      map.each do |name, dir|
        loc = dir if /^#{match}\./ =~ name
      end
      map.each do |name, dir|
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
    def list
      map.map{ |l| l.first }
    end

    #
    def map
      list = []

      # uri and linked seeds
      banks.each do |source|
        locs = Dir[File.join(source, '**/Sowfile')]
        locs = locs.map{ |l| File.dirname(l) }
        locs.each do |l|
          k = path_to_name(l.sub(source,''))
          list << [k, l]
        end
      end

      # plugin seeds
      locs = ::Plugin.find(File.join('sow', '**/Sowfile'))
      locs = locs.map{ |l| File.dirname(l) }
      locs.each do |l|
        k = path_to_name(l[l.rindex('sow')+4..-1])
        list << [k, l]
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

    #
    def install(resource)
      dir  = BANK
      out  = dir + uri_to_path(resource)
      name = File.basename(resource).chomp(File.extname(resource))
      if File.exist?(out + name)
        $stderr.puts "#{out + name} already exists"
        return # update ?
      end
      case resource
      when /^git\:/, /\.git$/
        cmd = "git clone #{resource} #{name}"
      when /^svn\:/
        cmd = "svn checkout clone #{resource} #{name}"
      else # local path
        cmd = "ln -s #{resource} #{out}"
      end
      if options.trial
        $stderr.puts("  mkdir -p #{out}")
        $stderr.puts("  cd #{out}")
        $stderr.puts("  #{cmd}")
      else
        FileUtils.mkdir_p(out)
        `cd #{out}; #{cmd}`
      end
    end

    #
    def uri_to_path(uri)
      uri = uri.dup
      uri.sub!(/^git\:\/\//, '')
      uri.sub!(/^svn\:\/\//, '')
      div = File.dirname(uri).split('/') # File::SEPARATOR ?
      div.reverse.join('.')
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

    #
    def update(resource=nil)
      dir = HOME #Pathname.new(XDG::Config.home + '/sow/seeds/')
      if resource
        out  = dir + uri_to_path(resource)
        if !out.exist
          raise '#{out} does not exists'
        end
        paths = [out]
      else
        paths = dir.glob('*')
      end
      paths.each do |out|
        if (out + '.git').exist?
          cmd = "cd #{out}; git pull origin master"
        elsif (out + '.svn').exist?
          cmd = "cd #{out}; svn update"
        end
        if options.trial
          $stderr.puts(cmd)
        else
          `#{cmd}`
        end
      end
    end

    # TODO
    def uninstall(resource)
      dir  = Pathname.new(XDG::Config.home + '/sow/seeds')
      out  = dir + uri_to_path(resource)
      #name = File.basename(resource).chomp(File.extname(resource))
      #dest = File.join(dir, name)
      #FileUtils.rm_rf(dest)
    end


    # TODO: Maybe save Sowfile in current directory?
    #
    # TODO: Anyway to set directory instead of Dir.pwd?
    def save(name)
      pot = config['pot'] || '~/.config/sow/pot'
      raise "seed needs a name" unless name
      dir = File.join(pot, name)
      #shell.mkdir_p(dir)
      copier = Copier.new(Dir.pwd, dir, options)
      copier.copy
      #shell.cp_r(Dir.pwd, dir)
      sowfile = File.join(dir, 'Sowfile')
      if !File.exist?(sowfile)
        File.open(sowfile, 'w'){ |f| f << 'template all' }
      end
      return dir
    end

    #
    def custom
    
    end

    #
    #def shell
    #  FileUtils
    #end

  end

end #module Sow

