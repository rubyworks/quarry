module Sow::Plugins

  # Cucumber seed.
  #
  class Cucumber < Script

    option :feature

    setup do
      if argument
        @dir = argument.chomp('/') + '/'
      else
        @dir = Dir["{test/,}features/"].first || 'features/'
      end
      metadata.feature = feature || 'generic'
    end

    manifest do
      if feature
        #TODO: copy support files if does not exists ?
        copy "features/__feature__.feature", @dir
      else
        copy "**/*", @dir, :cd => "features"
      end
    end

  end

end

