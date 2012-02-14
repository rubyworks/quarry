module Quarry

  # Mix this in with raised errors.
  module Error
    def self.exception(err,msg=nil)
      case err
      when String
        msg = err
        err = ($! || RuntimeError)
      when Class
        raise ArgumentError unless err < Exception
        err = err.new(msg)
      end
      err.extend self
      err
    end
  end

  class ArgumentError < ::ArgumentError
  end

  #
  class MissingTemplate < ArgumentError
    include Error
  end

  #
  class DuplicateTemplate < ArgumentError
    include Error
  end

end
