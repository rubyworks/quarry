require 'sow/cli/abstract'

module Sow::CLI

  # Remove a seed bank.
  class BankRemove < Abstract

    #
    def call(argv)
      manager.remove(argv.first)
    end

    #
    def opts
      super do |o|
        o.banner = "Usage: sow bank remove <name>"
      end
    end

  end

end

