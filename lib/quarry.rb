# Quarry namespace in which all components are defined.
#
# Quarry does use a few core extensions, but these are 
# all managed by Ruby Facets to help promote standardization
# in the area and reduce potential name conflicts.
#
module Quarry

  require 'erb'
  #require 'malt'
  require 'fileutils'
  require 'tmpdir'
  require 'uri'

  require 'finder'

  require 'quarry/version'
  require 'quarry/error'
  require 'quarry/cli'
  require 'quarry/config'
  require 'quarry/copier'
  require 'quarry/generator'
  require 'quarry/template'
  require 'quarry/template/management'
  require 'quarry/template/directory'
  require 'quarry/template/config'
  require 'quarry/template/readme'
  require 'quarry/template/script'
  require 'quarry/template/context'
  require 'quarry/template/script/metadata'
  require 'quarry/template/script/commit'  # transaction?

  #
  # Run quarry command line interface.
  #
  def self.cli(*argv)
    CLI.run(*argv)
  end

  #
  # Returns a template matching +name+.
  #
  def self.find(name)
    Template.find(name)
  end

  #
  # Initialize a directory for use with Quarry.
  #
  # TODO: Do we really need this?
  #
  def self.init(output)
    FileUtils.mkdir_p(File.join(output, '.0re'))
  end

  #
  # Print a list of all available ore.
  #
  def self.list
    Template.list
  end

  #
  # Fetch template from remote location.
  #
  def self.fetch(uri, options={})
    Template.fetch(uri, options)
  end

  #
  # Update scm based mine(s).
  #
  def self.update(name=nil)
    Template.update(name)
  end

  #
  # Save a directory as a mine to a user's personal mine bank, i.e. "silo".
  #
  def self.save(name, path=nil)
    Template.save(name, path)
  end

  #
  # Remove mine.
  #
  def self.remove(name)
    Template.remove(name)
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
  #
  #
  def self.help(name)
    Template.help(name)
  end

end
