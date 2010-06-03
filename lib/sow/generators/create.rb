require 'sow/generators/base'

module Sow

  module Generators

    # = Create Generator
    #
    class Create < Base

      #
      def copy(loc, src, dest, opts)
        tmp = File.join(loc, src)
        if File.directory?(tmp)
          copy_dir(loc, src, dest, opts)
        else
          copy_doc(loc, src, dest, opts)
        end
      end

      #
      def copy_dir(loc, src, dest, opts)
        if File.exist?(dest) #&& src == dest
          how = 'same'
        else
          mkdir_p(dest)
          how = 'create'
        end
        return how, dest
      end

      # TODO: Can .stub be used to prevent erb?
      def copy_doc(loc, src, dest, opts)
        tmp = File.join(loc, src)
        #ext = File.extname(src)
        #case ext
        #when '.erb'
        if opts['verbatim']
          how = (File.exist?(dest) ? 'update' : 'create')
          #file = tmp_file.chomp('.stub')
          cp(tmp, dest)
        else
          #file = tname.chomp('.erb') # old way
          text = erb(tmp) 
          how = (File.exist?(dest) ? 'update' : 'create')
          write(dest, text)
        end
        if opts['chmod']
          chmod(opts['chmod'], dest)
        end
        return how, dest
      end

      #
      #def erb(file)
      #  plugin.erb(file)
      #end

      #
      def clobber_term
        "overwrite"
      end

=begin
      ###
      def erb(file)
        text = nil
        temp = Context.new(plugin)
        begin
          text = temp.erb(file)
        rescue => e
          if trace?
            raise e
          else
            abort "template error -- #{file}"
          end
        end
        return text
      end


      ### Copy a directory varbatim; wich means
      ### just doing a mkdir.
      def verbatim_dir(tname, fname)
        if File.exist?(fname)
          #logger.report_create(fname, 'identical')
          'identical'
        else
          #logger.report_create(fname, 'create')
          mkdir_p(fname)
          'create'
        end
      end

      ### Copy a file verbatim.
      def verbatim_file(tname, fname)
        #ext = File.extname(tname)
        doc = File.join(source, tname)
        if File.exist?(fname)
          how = 'update'
        else
          how = 'create'
        end
        #file = tmp_file.chomp('.stub')
        #file = file.sub('__name__', name)
        cp(doc, fname)
        return how
      end
=end

    end

  end

end

