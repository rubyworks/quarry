module Sow::Plugins

  # Scaffold a ruby bin/ file.
  #
  class Bin < Script

    option :name

    setup do
      @name = argument || destination
      abort "Exectuable name is required." unless name
      abort "Executable name must be a single word." if /\w/ !~ name
    end

    manifest do
      copy 'bin/command.rb', "bin/#{@name}", :chmod => 0754
    end

  end

end

