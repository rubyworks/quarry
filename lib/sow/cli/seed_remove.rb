require 'sow/cli/abstract'

module Sow::CLI

  class SeedRemove < Abstract

    command 'seed remove'
    command 'seed rm'

    #
    def call(argv)
      name = argv.first
      if confirm?("remove #{name}")
        Sow.seed_remove(name)
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

