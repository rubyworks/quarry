require 'sow/cli/abstract'

module Sow::CLI

  # Clone a seed and place it into the seed bank.
  #
  class Bank < Abstract

    #
    command 'bank'

    #
    def call(argv)
      uri  = argv.shift
      name = argv.shift

      abort opts.to_s if argv.shift

      manager.clone(uri, :name=>name)
    end

    #
    def opts
      super do |o|
        o.banner = "Usage: sow bank <uri> [name]"
      end
    end

  end

end

