module Quarry

  #
  SCAFFOLD_MARKER = '.ore'

  #
  COPY_SCRIPT = "#{SCAFFOLD_MARKER}/copy.rb"

  #
  README_FILE = "#{SCAFFOLD_MARKER}/README{,.*}"

  #
  # Basenames of files to ignore in template files.
  #
  SCAFFOLD_IGNORE = %w{. .. .svn _}

  # Files to remove in template files.
  #SCAFFOLD_REMOVE = [CTRL]

  # Location of Quarry user configuration. Uses XDG directrory standard!!!
  #
  #XDG_CONFIG_HOME
  #
  HOME_CONFIG = ENV['SOW_CONFIG'] || '~/.quarry'

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
  #   export SOW_BANK="$XDG_CONFIG_HOME/quarry"
  #
  SOW_BANK = ENV['QUARRY_BANK'] || File.expand_path('~/.quarry')

  #
  # Where to store personal mines. This default to `$SOW_BANK/silo`.
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
