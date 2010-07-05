require 'sow/cli/abstract'
require 'sow/manager'

module Sow::CLI

  #
  class BankList < Abstract

    #
    def self.cli
      ['bank']
    end

    #
    def call(argv)
      banks = manager.banks
      banks.each do |bank|
        puts "  * #{bank}"
      end
    end

    def opts
      super do |o|
        o.banner = "Usage: sow bank"
      end
    end

  end

end

