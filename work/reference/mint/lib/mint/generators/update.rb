require 'sow/generators/create'

#--
# TODO: Could we use an "environment" settings file to specify environment variables to check for template variables?
#++

module Sow

  module Generators

    # = Update Generator
    #
    # Update is the same as the Create Generator with the exception
    # that it pulls all metadata from the destination.
    #
    class Update < Create

=begin
      ### Copy the file, processing it with ERB if
      ### it has an .erb extension. Unlike Create's
      ### this will skip pre-existant non-erb files.
      def copy_doc(src, dest)
        tmp = File.join(source, src)
        ext = File.extname(src)
        case ext
        when '.erb'
          text = erb(tmp)
          how = (File.exist?(dest) ? 'update' : 'create')
          write(dest, text)
        else
          if File.exist?(dest)
            how = 'skip'
          else
            how = 'create'
            cp(tmp, dest)
          end
        end
        return how, dest
      end
=end

    end

  end

end

