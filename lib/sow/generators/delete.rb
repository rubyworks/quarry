require 'sow/generators/base'

module Sow

  module Generators

    # = Delete Generator
    #
    class Delete < Base

      ###
      def manifest_prepare(manifest)
        manifest = manifest_glob(manifest)
        manifest = manifest_dest(manifest)
        manifest = manifest_sort(manifest)
        #manifest.each do |s, d|
        #  puts "%40s %40s" % [s, d]
        #end
        manifest = manifest_delete(manifest)
        manifest = manifest_safe(manifest)
        return manifest
      end

      ### Sort the manifest files before directory.
      ### This is opposite of Construct::Create.
      def manifest_sort(manifest)
        dirs, files = *manifest.partition{ |src, dest| (source + src).directory? }
        expanded = files.sort + dirs.sort
      end

      ### Add delete action to manifest.
      def manifest_delete(manifest)
        manifest.collect do |src, dest|
          [:delete, src, dest]
        end
      end

      ### Delete template file.
      def delete(src, dest)
        if File.exist?
          how = 'delete'
          rm(dest)
        else
          how = 'missing'
        end
        return how, dest
      end

    end#Destroyer

  end#Build

end#module Sow

