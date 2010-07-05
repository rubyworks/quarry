require 'sow/cli/abstract'

module Sow::CLI

  class SiloList < Abstract

    #
    def call(argv)
      silos = manager.silos
      if silos.empty?
        puts "No personal seeds found."
      else
        silos.each do |s|
          puts "  * #{s}"
        end
      end
    end

    #
    def opts
      super do |o|
        o.banner = "Usage: sow silo"
        o.separator "List your personal seeds."
      end
    end

  end

end

