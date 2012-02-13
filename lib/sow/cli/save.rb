require 'sow/cli/abstract'

module Sow::CLI

  class SeedSave < Abstract

    command 'seed save'

    #
    def call(argv)
      Sow.seed_save(*argv)
    end

    #
    def opts
      super do |o|
        o.banner = "Usage: sow save <name> [file ...]"
        o.separator "Save directory as seed to personal silo."
      end
    end

  end

end

