module Sow
module Extensions

  #
  module String

    def to_list
      split(/[:;\n]/).collect{ |e| e.strip }
    end

    def modulize
      capitalize.gsub('-','_').gsub(/_([a-z])/) {$1.upcase}
    end

    def pathize
      gsub(/([A-Z]\w)/, '_\1').downcase.sub(/^_/, '') #.sub('-','_')
    end

    def methodize
      gsub(/([A-Z]\w)/, '_\1').downcase.sub(/^_/, '').sub('-','_')
    end

  end

end
end

class String #:nodoc:
  include Sow::Extensions::String
end

