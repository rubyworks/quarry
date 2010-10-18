require 'sow/cli/abstract'

module Sow::CLI

  # Remove a seed bank.
  class BankUninstall < Abstract

    command 'bank uninstall'

    #
    def call(argv)
      name = argv.first
      if bank = Sow.manager.find_bank(name)
        if confirm?("uninstall #{bank.basename.to_s}")
          Sow.bank_uninstall(name)
        end
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

