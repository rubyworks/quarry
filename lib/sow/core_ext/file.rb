module Sow
module Extensions

  # NOTE: These are now in Facets.
  module File

    #
    def split_root(path)
      path_re = Regexp.new('[' + Regexp.escape(File::Separator + %q{\/}) + ']')
      path.split(path_re, 2)
    end

  end

end
end

class File #:nodoc:
  extend Sow::Extensions::File
end

