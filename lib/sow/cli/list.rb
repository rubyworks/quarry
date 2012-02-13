require 'sow/cli/abstract'

module Sow::CLI

  # List seeds.
  #
  class List < Abstract

    command 'list'
    command 'ls'

    #
    #def self.cli
    #  ['seed']
    #end

    #
    def call(argv)
      Sow.seed_list
    end

    #
    #def call(argv)
    #  seeds = manager.seed_list
    #  seeds.each do |seed|
    #    puts "  * #{bank}"
    #  end
    #end

    #
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

