module Quarry

  #
  # Template indicator.
  #
  TEMPLATE_DIRECTORY = '0RE'

  #
  # Basenames of files to ignore in templates.
  #
  #IGNORE_FILES = %w{. .. .svn}

  # Files to remove in template files.
  #REMOVE_FILES = [CTRL]

  # Location of Quarry user configuration. This directory defaults
  # to '~/.quarry', but it can be changed with the `$QUARRY_HOME`
  # environment variable. For example, if you want to use XDG base
  # directory standard, you can set that with:
  #
  #   export QUARRY_HOME="$XDG_CONFIG_HOME/quarry"
  #
  HOME = ENV['QUARRY_HOME'] || File.expand_path('~/.quarry')

  # Location relative to destination/project directory. If this needs
  # to be a hidden location trhen use `.quarry`, if not use `admin/quarry`.
  #
  WORK = '{.quarry,admin/quarry}'

  #
  # File pattern for looking up user matadata.
  #
  HOME_METADATA = File.join(HOME,'metadata.{yml,yaml}')

  #
  # File pattern for looking up desination matadata.
  #
  # FIXME: 
  #
  WORK_METADATA = '{.quarry,.config/quarry,config/quarry}/metadata.{yml,yaml}'

  #
  # Where to install templates. By default this is `$QUARRY_HOME/templates`.
  #
  QUARRY_BANK = ENV['QUARRY'] || File.join(HOME, 'templates')

  #
  # Where to store personal mines. This default to `$SOW_BANK/silo`.
  # 
  #SOW_SILO = ENV['SOW_SILO'] || SOW_BANK + '/silo'

  #
  # Edit marker.
  #
  EDIT_MARKER = /___(.*?)___/

  ##
  ## Full path to directory in which quarry stores local ore.
  ##
  #def self.bank_folder
  #  @bank_folder ||= Pathname.new(File.expand_path(QUARRY_BANK))
  #end

  #
  #def self.read_setting(name, default=nil)
  #  file = SOW_CONFIG + "/settings/#{name}"
  #  if File.exist?(file)
  #    File.read(file).strip
  #  else
  #    default
  #  end
  #end

end
