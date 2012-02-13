require 'sow/cli/abstract'

module Sow::CLI

  # Remove a seed from the seed bank.
  #
  class Remove < Abstract

    command 'remove'
    command 'rm'

    #
    def call(argv)
      name = argv.first
      if confirm?("remove #{name}")
        Sow.seed_remove(name)
      end
    end

    #
    #def call(argv)
    #  name = argv.first
    #  if bank = Sow.manager.find_bank(name)
    #    if confirm?("uninstall #{bank.basename.to_s}")
    #      Sow.bank_uninstall(name)
    #    end
    #  end
    #end

    #
    def opts
      super do |o|
        o.banner = "Usage: sow remove [name]"
        o.separator "Remove seed from seed bank."
      end
    end

  end

end

