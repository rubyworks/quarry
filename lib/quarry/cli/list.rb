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
      templates = Quarry::Template.templates
      groups    = templates.group_by{ |t| t.type }

      groups.each do |group, tmpls|
        puts "#{group}"
        tmpls.each do |tmpl|
          puts "  * #{tmpl.name}"
        end
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

