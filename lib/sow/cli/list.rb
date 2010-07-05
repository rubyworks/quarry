require 'sow/cli/abstract'
require 'sow/manager'

module Sow::CLI

  #
  class List < Abstract

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
      end
    end

  end

end

