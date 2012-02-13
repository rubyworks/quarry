module Sow

  # Location of Sow user configuration. Uses XDG directrory standard!!!
  #
  #XDG_CONFIG_HOME
  #
  HOME_CONFIG = ENV['SOW_CONFIG'] || '~/.sow'

  # File pattern for looking up user matadata.
  HOME_METADATA = File.join(HOME_CONFIG,'sow/metadata.{yml,yaml}')

  #
  # File pattern for looking up desination matadata.
  #
  # FIXME: 
  #
  DEST_METADATA = '{.sow,.config,config}/sow/metadata.{yml,yaml}'

  #
  SEED_MARK = ".seed"

  #
  # Where to install seed banks. This sow configuration directory defaults
  # to '~/.sow', but it can be changes with the `$SOW_BANK` environment
  # variable. For example, if you want to use XDG base directory standard,
  # you can set that with:
  #
  #   export SOW_BANK="$XDG_CONFIG_HOME/sow"
  #
  SOW_BANK = ENV['SOW_BANK'] || File.expand_path('~/.sow')

  #
  # Where to store personal seeds. This default to `$SOW_BANK/silo`.
  # 
  #SOW_SILO = ENV['SOW_SILO'] || SOW_BANK + '/silo'

  #
  # File extensions that are always be considered verbatim.
  #
  VERBATIM_EXTENSIONS = %w{.jpg .png .gif .pdf .ogv .ogg}

  #
  # Edit marker.
  #
  EDIT_MARKER = /___(.*?)___/

end
