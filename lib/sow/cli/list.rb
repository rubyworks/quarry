require 'sow/cli/abstract'
require 'sow/manager'

module Sow::CLI

  #
  class BankList < Abstract

    #
    def call(argv)
      list = manager.list
      list.each do |seed|
        puts "  * #{seed}"
      end
    end

    def opts
      super do |o|
        o.banner = "Usage: sow bank"
      end
    end

  end

end

