require 'sow/cli/abstract'

module Sow::CLI

  class SeedList < Abstract

    command 'list'  # TODO make a separate command with better layout
    command 'seed list'
    command 'seed ls'

    #
    #def self.cli
    #  ['seed']
    #end

    #
    def call(argv)
      Sow.seed_list
    end

    def opts
      super do |o|
        o.banner = "Usage: sow seed"
        o.separator "List all available seeds."
      end
    end

    #
    #def call(argv)
    #  silos = manager.silos
    #  if silos.empty?
    #    puts "No personal seeds found."
    #  else
    #    silos.each do |s|
    #      puts "  * #{s}"
    #    end
    #  end
    #end

  end

end

