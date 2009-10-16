require 'yaml'
require 'ostruct'

module Sow

  class Usage < OpenStruct

    def initialize(path)
      super()
      if File.exist?(path)
        data = YAML.load(path)
        data.each do |k,v|
          __send__("#{k}=", v)
        end
      end
    end

  end

end

