require 'sow/cli/abstract'

module Sow::CLI

  # Remove a seed bank.
  class BankUninstall < Abstract

    #
    def self.cli
      ['bank', 'uninstall']
    end

    #
    def call(argv)
      name = argv.first
      bank = manager.find_bank(name)
      if confirm?("uninstall #{bank.basename.to_s}")
        manager.uninstall(name)
      end
    end

    #
    def opts
      super do |o|
        o.banner = "Usage: sow bank uninstall <name>"
      end
    end

  end

end

