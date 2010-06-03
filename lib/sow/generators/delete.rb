require 'sow/generators/base'

module Sow

  module Generators

    # = Delete Generator
    #
    #--
    # TODO: should force option be require to do this?
    #       And without force it just reports what would be deleted?
    #++
    class Delete < Base

      def mark; 'delete'; end

      #
      def actionlist_check(list)
        list
      end

      # Sort the manifest files before directory.
      # This is opposite of Construct::Create.
      def actionlist_sort(list)
        list.reverse
        #dirs, files = *list.partition{ |src, dest, opts| (source + src).directory? }
        #files.sort{|a,b| a[1]<=>b[1]} + dirs.sort{|a,b| a[1]<=>b[1]}
      end

      # Delete template file.
      def delete(loc, src, dest, opts)
        if File.exist?(dest)
          how = 'delete'
          begin
            rm(dest)
          rescue Errno::ENOTEMPTY
            how = 'skip'
          end
        else
          how = 'missing'
        end
        return how, dest
      end

      #
      def clobber_term
        "delete"
      end

    end#class Delete

  end#module Generators

end#module Sow

