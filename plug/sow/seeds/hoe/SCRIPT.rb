# How plugin, to make up for the fact the Sow clobber's
# Hoe's +sow+ command.
#
# It's silly for Hoe to have a command called +sow+ when
# it could just as well used +hoe+ andyway.

module Sow::Plugins

  # Scaffold a new Hoe-ready project
  #
  class Hoe < Script

    option :name

    setup do
      abort "Project name argument required." unless name
      metadata.name = name
    end

    manifest do
      copy "**/*", '.'
    end

  end

end

