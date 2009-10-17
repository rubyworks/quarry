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

# Facets More
require 'facets/ostruct'
require 'facets/pathname'

# ARE THESE NEEDED?
#require 'facets/yaml' # for to_yamlfrag
#require 'facets/string/snakecase'
#require 'facets/string/camelcase'
#require 'sow/openext'

class String

  def to_list
    split(/[:;\n]/).collect{ |e| e.strip }
  end

end

# NOTE: These are now in Facets.

=begin
module File

  #
  def split_root(path)
    path_re = Regexp.new('[' + Regexp.escape(File::Separator + %q{\/}) + ']')
    path.split(path_re, 2)
  end

end
=end

