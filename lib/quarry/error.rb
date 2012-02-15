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
    include Error
  end

  #
  class MissingTemplate < ArgumentError
  end

  #
  class DuplicateTemplate < ArgumentError
  end

end
