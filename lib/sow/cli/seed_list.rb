require 'sow/cli/abstract'

module Sow::CLI

  class SeedList < Abstract

    #
    def self.cli
      ['seed']
    end

    #
    def call(argv)
      seeds = manager.seeds
      seeds.each do |seed|
        puts "  * #{seed}"
      end
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

