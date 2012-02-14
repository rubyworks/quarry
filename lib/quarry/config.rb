module Quarry

  #
  # Tempalte configuration file.
  #
  CONFIG_FILE = 'template.yml'  # TODO: rename to ore.yml ?

  #
  # Basenames of files to ignore in templates.
  #
  IGNORE_FILES = %w{. .. .svn}

  # Files to remove in template files.
  #REMOVE_FILES = [CTRL]

  # Location of Quarry user configuration. Uses XDG directrory standard!!!
  #
  HOME_CONFIG = ENV['QUARRY_CONFIG'] || '~/.quarry'

  # File pattern for looking up user matadata.
  HOME_METADATA = File.join(HOME_CONFIG,'metadata.{yml,yaml}')

  #
  # File pattern for looking up desination matadata.
  #
  # FIXME: 
  #
  DEST_METADATA = '{.quarry,.config,config}/quarry/metadata.{yml,yaml}'

  #
  # Where to install mines. This quarry configuration directory defaults
  # to '~/.quarry', but it can be changes with the `$SOW_BANK` environment
  # variable. For example, if you want to use XDG base directory standard,
  # you can set that with:
  #
  #   export QUARRY="$XDG_CONFIG_HOME/quarry"
  #
  QUARRY_BANK = ENV['QUARRY'] || File.expand_path('~/.quarry')

  #
  # Where to store personal mines. This default to `$SOW_BANK/silo`.
  # 
  #SOW_SILO = ENV['SOW_SILO'] || SOW_BANK + '/silo'

  #
  # File extensions that are always be considered verbatim.
  #
  VERBATIM_EXTENSIONS = %w{.jpg .png .gif .mp3 .pdf .ogv .ogg}

  #
  # Edit marker.
  #
  EDIT_MARKER = /___(.*?)___/

  #
  # Full path to directory in which quarry stores local ore.
  #
  def self.bank_folder
    @bank_folder ||= Pathname.new(File.expand_path(QUARRY_BANK))
  end

  # THINK: Should work_folder be a lookup of project root?

  #
  # Current working directory.
  #
  def self.work_folder
    @work_folder ||= Pathname.new(Dir.pwd) #self.class.bank_folder
  end

  ##
  ## Full path to personal bank.
  ##
  ##def self.silo_folder
  #  @silo_folder ||= (
  #    Pathname.new(File.expand_path(SOW_SILO))
  #  )
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
