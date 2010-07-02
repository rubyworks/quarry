require 'sow/cli/abstract'

module Sow::CLI

  # Update a seed bank.
  class BankUpdate < Abstract

    #
    def call(argv)
      manager.update(argv.first)
    end

    #
    def opts
      super do |o|
        o.banner = "Usage: sow bank update [name]"
      end
    end

  end

end

