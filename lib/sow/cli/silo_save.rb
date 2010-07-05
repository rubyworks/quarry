require 'sow/cli/abstract'

module Sow::CLI

  class SiloSave < Abstract

    #
    def call(argv)
      manager.save(*argv)
    end

    #
    def opts
      super do |o|
        o.banner = "Usage: sow bank save <name>"
        o.separator "Save directory as seed to personal seed bank."
      end
    end

  end

end

