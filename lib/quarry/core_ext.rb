# Facets Core
require 'facets/kernel/ask'
require 'facets/dir/recurse'
require 'facets/hash/to_h'
require 'facets/hash/rekey'

# Facets Standard
require 'facets/pathname'
require 'facets/ostruct'

class OpenStruct #:nodoc:
  # Missing from early version of Facets
  def to_ostruct
    self
  end
end

=begin
require 'erb'
require 'fileutils'

# Facets Core
require 'facets/kernel/ask'
require 'facets/hash/rekey'
require 'facets/dir/multiglob'
require 'facets/file/rootname'
require 'facets/file/split_root'
require 'facets/module/basename'
require 'facets/string/tab'
require 'facets/string/pathize'
require 'facets/string/modulize'
require 'facets/string/methodize'

# ARE THESE NEEDED?
#require 'facets/yaml' # for to_yamlfrag
#require 'facets/string/snakecase'
#require 'facets/string/camelcase'
#require 'quarry/openext'

class String

  def to_list
    split(/[:;\n]/).collect{ |e| e.strip }
  end

end
=end

