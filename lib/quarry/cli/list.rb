require 'quarry/cli/abstract'

module Quarry::CLI

  # List available "ore".
  #
  class List < Abstract

    command 'list'
    command 'ls'

    #
    #def self.cli
    #  ['mine']
    #end

    #
    # List all available ore.
    #
    def call(argv)
      names = Quarry.list
      names.each do |name|
        puts "  * #{name}"
      end
    end

    #
    #def call(argv)
    #  mines = manager.mine_list
    #  mines.each do |mine|
    #    puts "  * #{bank}"
    #  end
    #end

    #
    def opts
      super do |o|
        o.banner = "Usage: quarry mine"
        o.separator "List all available mines."
      end
    end

    #
    #def call(argv)
    #  silos = manager.silos
    #  if silos.empty?
    #    puts "No personal mines found."
    #  else
    #    silos.each do |s|
    #      puts "  * #{s}"
    #    end
    #  end
    #end

  end

end

