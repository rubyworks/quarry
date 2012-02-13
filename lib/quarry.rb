# Quarry namespace in which all components are defined.
#
# Quarry does use a few core extensions, but these are 
# all managed by Ruby Facets to help promote standardization
# in the area and reduce potential name conflicts.
#
module Quarry

  require 'quarry/version'
  require 'quarry/manager'

  # Run quarry command line interface.
  def self.cli(*argv)
    require 'quarry/cli'
    CLI.run(*argv)
  end

  # Returns a cached instance of mine Manager.
  def self.manager
    @manager ||= Manager.new
  end

  # Returns a Seed matching +name+.
  def self.find(name)
    manager.find(name)
  end

  # Initialize a directory for use with Quarry.
  # TODO: Do we really need this?
  def self.init(output)
    FileUtils.mkdir_p(File.join(output, '.quarry'))
  end

  # Print a list of installed mine banks.
  #def self.bank_list
  #  banks = manager.banks
  #  banks.each do |bank|
  #    puts "  * #{bank}"
  #  end
  #end

  # Fetch ore from URL.
  def self.fetch(uri, options={})
    manager.fetch(uri, options)
  end

  #
  # Update scm based mine(s).
  #
  def self.update(name=nil)
    manager.update(name)
  end

  #
  # Print a list of all available ore.
  #
  def self.list
    manager.list
  end

  #
  # Save a directory as a mine to a user's personal mine bank, i.e. "silo".
  #
  def self.save(name, path=nil)
    manager.save(name, path)
  end

  #
  # Remove mine.
  #
  def self.remove(name)
    manager.remove(name)
  end

  #
  # Use Quarry's managed copy utility to copy the contents of one directory to
  # another.
  #
  def self.copy(from, to, options={})
    copier = Quarry::Copier.new(from, to, options)
    copier.copy
  end

  # Undo the previous quarrying.
  #
  # FIXME: what is being restored? Also, while this will overwrite changed
  # files, it won't remove new files created by the mine. Need to fix!
  #
  # TODO: Use the underlying SCM to handle this!!!
  #
  def self.undo(output, options)
    backup = Dir[File.join(output, '.quarry/undo/*')].sort.last
    copier = Quarry::Copier.new(backup, output, options)
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
