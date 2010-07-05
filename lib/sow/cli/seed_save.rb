require 'sow/cli/abstract'

module Sow::CLI

  class SeedSave < Abstract

    #
    def self.cli
      ['seed', 'save']
    end

    #
    def call(argv)
      manager.save(*argv)
    end

    #
    def opts
      super do |o|
        o.banner = "Usage: sow seed save <name>"
        o.separator "Save directory as seed to personal silo."
      end
    end

  end

end

