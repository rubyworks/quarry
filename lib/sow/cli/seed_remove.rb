require 'sow/cli/abstract'

module Sow::CLI

  class SeedRemove < Abstract

    #
    def self.cli
      ['seed', /(remove|rm)/]
    end

    #
    def call(argv)
      name = argv.first
      if confirm?("remove #{name}")
        manager.remove(name)
      end
    end

    #
    def opts
      super do |o|
        o.banner = "Usage: sow seed remove [name]"
        o.separator "Remove seed from personal silo."
      end
    end

  end

end

