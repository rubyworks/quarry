require 'sow/cli/abstract'

module Sow::CLI

  class SiloRemove < Abstract

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
        o.banner = "Usage: sow bank save [name]"
        o.separator "Save directory as seed to personal seed bank."
      end
    end

  end

end

