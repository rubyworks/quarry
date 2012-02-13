module Sow

  class Sowfile

    # Encapsulate a set of copy transactions. This is better than using
    # copy directly b/c it allows multiple copy commands to be resolved
    # into a single copy operation, which can prevent duplicate copying.
    # The last copy command takes precedence over the first.
    #
    class Commit

      #
      attr :sower

      #
      attr :copy_list

      #
      def initialize(sower, &block)
        @sower       = sower
        @copy_list   = {}
        @append_list = {}
        instance_eval(&block)
      end

      #
      def copy(options={})
        from  = options.delete(:from)
        to    = options.delete(:to)
        files = options.delete(:files) || '**/*'

        tmpl = sower.seed.directory

        list = []

        if from
          (tmpl + from).glob_relative(files).each do |f|
            next if f.basename.to_s == "Sowfile"
            next if f.basename.to_s == "_Sowfile"
            list << [File.join(from, f), f.to_s]
          end
        else
          tmpl.glob_relative(files).each do |f|
            next if f.basename.to_s == "Sowfile"
            next if f.basename.to_s == "_Sowfile"
            list << [f.to_s, f.to_s]
          end
        end

        if to
          list.map!{ |src, dest| [src, File.join(to,dest)] }
        end

        list.each do |src, dest|
          @copy_list[dest] = [src, options]
        end
      end

      #
      def append(file, text)
        @append_list << [file, text]
      end

      # Copies occur before appends.
      def commit!
        @copy_list.each do |dest, (src, opts)|
          sower.template(src, dest, opts)
        end
        @append_list.each do |file, text|
          sower.append(file, text)
        end
      end

    end

  end

end
