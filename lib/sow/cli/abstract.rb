require 'optparse'
require 'sow/manager'

module Sow
module CLI

  #
  def self.registry
    @registry ||= {}
  end

  #
  class Abstract

    #
    def self.command(string)
      CLI.registry[string] = self
    end

    #
    #def self.cli
    #  [name.split('::').last.downcase]
    #end

    #
    #def self.inherited(subclass)
    #  CLI.registry << subclass
    #end

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
      @options = {}
    end

    #
    def run(*argv)
      opts.parse!(argv)
      call(argv)
    end

    #
    def manager
      @manager ||= Manager.new(options)
    end

    # Get a confirmation from the user. If $FORCE is true,
    # assume the answer it 'yes'.
    def confirm?(message)
      ans = $FORCE ? 'y' : ask("Confirm #{message} (y/N)? ")
      case ans.strip.downcase
      when 'y', 'yes'
        true
      else
        false
      end
    end

    #
    def opts(&block)
      opt = OptionParser.new(&block)
      opt.on('--dryrun'      ){ $DRYRUN = true }
      opt.on('--force'       ){ $FORCE  = true }
      opt.on('--debug'       ){ $DEBUG  = true }
      opt.on('--help', '-h'  ){ puts opt; exit }
      opt
    end

  end

end
end
