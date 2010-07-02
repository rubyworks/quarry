require 'sow/generator'
require 'ostruct'

module Sow

  #$DEBUG = true

  #
  module CLI

    # Entry point for commandline interface.
    def self.run(*argv)
      cmd = argv.shift
      case cmd
      when 'help'
        cmdc = CLI::Help
        args = argv
      when 'bank', '-b', '--bank'
        cmdc, args = bank(argv)
      when 'init', '-i', '--init'
        cmdc = CLI::Init
        args = argv
      when 'new', '-n', '--new'
        cmdc = CLI::New
        args = argv
      when 'gen', '-g', '--gen'
        cmdc = CLI::Plant
        args = argv
      when 'undo', '-u', '--undo'
        cmdc = CLI::Undo
        args = argv
      else
        cmdc = CLI::Plant
        args = [cmd, *argv]
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

    #
    def self.bank(argv)
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
      return cmdc, args
    end

  end

end

require 'sow/cli/abstract'
require 'sow/cli/new'
require 'sow/cli/plant'
require 'sow/cli/undo'

require 'sow/cli/bank_list'
require 'sow/cli/bank_install'
require 'sow/cli/bank_update'
require 'sow/cli/bank_remove'
require 'sow/cli/bank_save'

require 'sow/cli/help'

