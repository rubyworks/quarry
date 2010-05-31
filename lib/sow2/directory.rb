module Sow

  #
  class Directory

    attr :pathname

    #
    def initialize(pathname)
      @pathname = Pathname.new(pathname)
    end

    #
    def glob(*patterns)
      found = []
      patterns.each do |pattern|
        found.concat(pathname.glob(pattern))
      end
      found.map{ |f| f.sub(path,'')
    end

    #
    def size(path)
      (pathname + path).size
    end

    #
    def md5(path)
      (pathname + path).md5
    end

    #
    def mtime(path)
      (pathname + path).mtime
    end

    #
    def ctime(path)
      (pathname + path).ctime
    end

    #
    def atime(path)
      (pathname + path).atime
    end

    #
    def read(path)
      (pathname + path).read
    end

  end

end
