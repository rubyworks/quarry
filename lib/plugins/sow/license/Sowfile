#

module Sow::Plugins

  # Add specified license to your project.

  class License < Script

    LICENSES = %w[gpl lgpl mit]

    argument :license

    setup do
      lic = license.downcase
      abort "License name required" unless LICENSES.include?(lic)
      metadata.license = lic.upcase
    end

    manifest do
      copy "META/*", metadir
      copy "*", '.', :cd => license.downcase
    end

  end

end

