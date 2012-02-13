require 'quarry/cli/abstract'

module Quarry::CLI

  # Remove a mine.
  #
  class Remove < Abstract

    command 'remove'
    command 'rm'

    #
    def call(argv)
      name = argv.first
      mine = Quarry.find(name)
      if mine
        if confirm?("remove #{mine.name}")
          Quarry.remove(name)
        end
      else
        raise "no such mine -- #{name}"
      end
    end

    #
    def opts
      super do |o|
        o.banner = "Usage: quarry remove [name]"
        o.separator "Remove a mine."
      end
    end

  end

end

