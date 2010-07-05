require 'sow/generator'
require 'ostruct'

module Sow

  #
  module CLI

    # Entry point for commandline interface.
    def self.run(*argv)
      argv.shift if argv.first == '-'
      case cmd = argv.shift
      when 'help', '-h', '--help'
        cmdc = CLI::Help
      when 'bank', '-b', '--bank'
        cmdc = bank(argv)
      when 'silo', '-s', '--silo'
        cmdc = silo(argv)
      when 'seed', 'seeds', 'list', '-l', '--list'
        cmdc = CLI::List
      when 'init', '-i', '--init'
        cmdc = CLI::Init
      when 'new', '-n', '--new'
        cmdc = CLI::New
      when 'gen', '-g', '--gen'
        cmdc = CLI::Gen
      when 'undo', '-u', '--undo'
        cmdc = CLI::Undo
      when 'copy', '-c', '--copy'
        cmdc = CLI::Copy
      else
        cmdc = CLI::Gen
        argv.unshift(cmd) if argv
      end

      if $DEBUG
        cmdc.run(*argv)
      else
        begin
          cmdc.run(*argv)
        rescue => error
          $stderr << error.to_s + "\n"
        end
      end
    end

    #
    def self.bank(argv)
      case cmd = argv.shift
      when 'install'
        cmdc = CLI::BankInstall
      when 'uninstall'
        cmdc = CLI::BankUninstall
      when 'update'
        cmdc = CLI::BankUpdate
      else
        cmdc = CLI::BankList
        argv.unshift(cmd) if cmd
      end
      return cmdc
    end

    #
    def self.silo(argv)
      case cmd = argv.shift
      when 'save'
        cmdc = CLI::SiloSave
      when 'remove', 'rm'
        cmdc = CLI::SiloRemove
      else
        cmdc = CLI::SiloList
        argv.unshift(cmd) if cmd
      end
      return cmdc
    end

  end

end

require 'sow/cli/abstract'

require 'sow/cli/list'
require 'sow/cli/new'
require 'sow/cli/gen'
require 'sow/cli/undo'
require 'sow/cli/copy'

require 'sow/cli/bank_list'
require 'sow/cli/bank_install'
require 'sow/cli/bank_update'
require 'sow/cli/bank_uninstall'

require 'sow/cli/silo_list'
require 'sow/cli/silo_save'
require 'sow/cli/silo_remove'

require 'sow/cli/help'

