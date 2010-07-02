module Sow
module CLI

  #
  def self.registry
    @registry ||= []
  end

  #
  class Abstract

    #
    def self.inherited(subclass)
      CLI.registry << subclass
    end

    #
    def self.run(*argv)
      new.run(*argv)
    end

    #
    def options
      @options
    end

    #
    def initialize()
      @options = OpenStruct.new
    end

    #
    def run(*argv)
      opts.parse!(argv)
      call(argv)
    end

    #
    def opts(&block)
      opt = OptionParser.new(&block)
      opt.on('--dryrun'      ){ $DRYRUN = true }
      opt.on('--debug'       ){ $DEBUG  = true }
      opt.on('--help', '-h'  ){ puts opt; exit }
      opt
    end

    #
    def manager
      @manager ||= Manager.new(options)
    end

  end

end
end
