require 'sow/generator'
require 'ostruct'

module Sow

  #$DEBUG = true

  #
  module CLI

    # Entry point for commandline interface.
    def self.run(*argv)
      name = argv.shift
      case name
      when 'bank'
        case argv.first
        when 'install'
          argv.shift
          cmdc = CLI::BankInstall
          args = argv
        when 'update'
          argv.shift
          cmdc = CLI::BankUpdate
          args = argv
        when 'remove'
          argv.shift
          cmdc = CLI::BankRemove
          args = argv
        else
          cmdc = CLI::BankList
          args = argv
        end
      when 'help'
        cmdc = CLI::Help
        args = argv
      else
        cmdc = CLI::Plant
        args = [name, *argv]
      end       

      if $DEBUG
        cmdc.run(*args)
      else
        begin
          cmdc.run(*args)
        rescue Exception => error
          $stderr << error.to_s + "\n"
        end
      end
    end
  end

end

require 'sow/cli/abstract'
require 'sow/cli/plant'
require 'sow/cli/uproot'

require 'sow/cli/list'
require 'sow/cli/install'
require 'sow/cli/update'
require 'sow/cli/remove'

require 'sow/cli/help'
