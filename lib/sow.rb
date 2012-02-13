# = Sow
#
# Sow namespace in which all Sow components are defined.
#
# Sow does use a number of core extensions, but these are 
# all managed by Ruby Facets to help promote standardization
# in the area and reduce potential name conflicts.
module Sow

  require 'sow/version'
  require 'sow/manager'
  #require 'sow/sower'

  # Run sow command line interface.
  def self.cli(*argv)
    require 'sow/cli'
    CLI.run(*argv)
  end

  # Returns a cached instance of seed Manager.
  def self.manager
    @manager ||= Manager.new
  end

  # Returns a Seed matching +name+.
  def self.find_seed(name)
    manager.find_seed(name)
  end

  # Initialize a directory for use with Sow.
  # TODO: Do we really need this?
  def self.init(output)
    FileUtils.mkdir_p(File.join(output, '.sow'))
  end

  # Print a list of installed seed banks.
  #def self.bank_list
  #  banks = manager.banks
  #  banks.each do |bank|
  #    puts "  * #{bank}"
  #  end
  #end

  # Fetch seed.
  def self.fetch_seed(uri, options={})
    manager.fetch_seed(uri, options)
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
    names = manager.seed_list
    names.each do |name|
      puts "  * #{name}"
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
  def self.undo(output, options)
    backup = Dir[File.join(output, '.sow/undo/*')].sort.last
    copier = Sow::Copier.new(backup, output, options)
    copier.copy
    FileUtils.rm_r(backup)
  end

  #
  def self.help(name)
    puts
    puts manager.help(name)
    puts
  end

end
