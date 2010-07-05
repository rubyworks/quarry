require 'sow/cli/abstract'

module Sow::CLI

  # Install a seed bank.
  class BankInstall < Abstract

    def call(argv)
      manager.install(*argv)
    end

    def opts
      super do |o|
        o.banner = "Usage: sow bank install <uri>"
      end
    end

  end

end

