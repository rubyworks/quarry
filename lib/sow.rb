require 'yaml'

# = Sow
#
# Sow namespace in which all Sow comppnents are defined.
#
# Sow does use a number of core extensions, but these are 
# all managed by Ruby Facets to help promote standardized
# in the area and reduce potential name conflicts.
module Sow
  DIRECTORY = File.dirname(__FILE__) + '/sow'

  PROFILE = YAML.load(File.new(DIRECTORY + '/profile.yml'))
  PACKAGE = YAML.load(File.new(DIRECTORY + '/version.yml'))

  VERSION = PACKAGE.values_at('major','minor','patch','build').compact.join('.')

  #
  def self.const_missing(name)
    key = name.to_s.downcase
    if PACKAGE.key?(key)
      PACKAGE[key]
    elsif profile.key?(key)
      PROFILE[key]
    else
      super(name)
    end
  end

  # Run sow command.
  def self.main(*argv)
    CLI.run(*argv)
  end

end

require 'sow/cli'

