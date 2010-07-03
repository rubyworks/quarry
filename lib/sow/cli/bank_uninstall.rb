require 'sow/cli/abstract'

module Sow::CLI

  # Remove a seed bank.
  class BankUninstall < Abstract

    #
    def call(argv)
      manager.uninstall(argv.first)
    end

    #
    def opts
      super do |o|
        o.banner = "Usage: sow bank remove <name>"
      end
    end

  end

end

