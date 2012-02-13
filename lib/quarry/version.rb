module Quarry

  #
  # Local library directory.
  #
  def self.__DIR__
    File.dirname(__FILE__)
  end

  #
  # Access to project metadata.
  #
  def self.metadata
    @metadata ||= (
      require 'yaml'
      YAML.load(File.new(__DIR__ + '/../quarry.yml'))
    )
  end

  #
  # Try missing constants as metadata lookups.
  #
  def self.const_missing(name)
    key = name.to_s.downcase
    metadata[key] || super(name)
  end

end

# Remove VERSION constant becuase Ruby 1.8~ gets in the way of Quarry::VERSION.
Object.__send__(:remove_const, :VERSION) if Object.const_defined?(:VERSION)

