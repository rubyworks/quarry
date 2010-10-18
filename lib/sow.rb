# = Sow
#
# Sow namespace in which all Sow components are defined.
#
# Sow does use a number of core extensions, but these are 
# all managed by Ruby Facets to help promote standardized
# in the area and reduce potential name conflicts.
module Sow

  #
  DIRECTORY = File.dirname(__FILE__) + '/sow'

  # Load and cache project profile.
  def self.profile
    @profile ||= (
      require 'yaml'
      YAML.load(File.new(DIRECTORY + '/PROFILE.yml'))
    )
  end

  # Load and cache project version file.
  def self.version
    @version ||= (
      require 'yaml'
      YAML.load(File.new(DIRECTORY + '/VERSION.yml'))
    )
  end

  # Lookup project metadata.
  def self.const_missing(name)
    key = name.to_s.downcase
    version[key] || profile[key] || super(name)
  end

  # Run sow command line interface.
  def self.cli(*argv)
    require 'sow/cli'
    CLI.run(*argv)
  end

  # Returns a cached instance of seed Manager.
  def self.manager
    @manager ||= Manager.new
  end

  # Initialize a directory for use with Sow.
  # TODO: Do we really need this?
  def self.init(output)
    FileUtils.mkdir_p(File.join(output, '.sow'))
  end

  # Print a list of installed seed banks.
  def self.bank_list
    banks = manager.banks
    banks.each do |bank|
      puts "  * #{bank}"
    end
  end

  # Install a new seed bank.
  def self.bank_install(*arguments)
    manager.install(*arguments)
  end

  # Uninstall a seed bank.
  def self.bank_uninstall(name)
    bank = manager.find_bank(name)
    if confirm?("uninstall #{bank.basename.to_s}")
      manager.uninstall(name)
    end
  end

  # Update a seed bank.
  def self.bank_update(name=nil)
    manager.update(name)
  end

  # Print a list of all available seeds.
  def self.seed_list
    seeds = manager.seeds
    seeds.each do |seed|
      puts "  * #{seed}"
    end
  end

  # Save a directory as a seed to a user's personal seed bank, i.e. "silo".
  def self.seed_save(name, path=nil)
    manager.save(name, path)
  end

  # Remove seed from user silo.
  def self.seed_remove(name)
    manager.remove(name)
  end

  # Use Sow's managed copy utility to copy the contents of one directory to
  # another.
  def self.copy(from, to, options={})
    copier = Sow::Copier.new(from, to, options)
    copier.copy
  end

  # Undo the previous sowing.
  # FIXME: what is being restored? Also, while this will overwrite changed
  # files, it won't remove new files created by the seed. Need to fix!
  def undo(output, options)
    backup = Dir[File.join(output, '.sow/undo/*')].sort.last
    copier = Sow::Copier.new(backup, output, options)
    copier.copy
    FileUtils.rm_r(backup)
  end

end

# Remove VERSION constant becuase Ruby 1.8~ gets in the way of Sow::VERSION.
Object.__send__(:remove_const, :VERSION) if Object.const_defined?(:VERSION)
