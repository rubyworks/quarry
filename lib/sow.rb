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

  profile = YAML.load(File.new(DIRECTORY + '/profile.yml'))
  verfile = YAML.load(File.new(DIRECTORY + '/version.yml'))

  VERSION = verfile.values_at('major','minor','patch','state','build').compact.join('.')

  #
  def self.const_missing(name)
    key = name.to_s.downcase
    if verfile.key?(key)
      verfile[key]
    elsif profile.key?(key)
      profile[key]
    else
      super(name)
    end
  end
end

