require 'sow/cli/abstract'

module Sow::CLI

  class BankSave < Abstract

    #
    def call(argv)
      manager.save(argv.first)
    end

    #
    def opts
      super do |o|
        o.banner = "Usage: sow bank save [name]"
        o.separator "Save directory as seed to personal seed bank."
      end
    end

  end

end

