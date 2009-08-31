### = OpenExtension
###
### This class evaluates the generator.rb script in 
### a generator's files. Hence the Generator class provides the 
### DSL available to generator scripts.
class OpenExtension < Module
  PRESERVE = /^(__|inspect$|instance_|object_|define_|send$|module_)/
  instance_methods.each{ |m| undef_method(m) unless m.to_s =~ PRESERVE }

  def initialize(code=nil, &block)
    module_eval(code)   if code
    module_eval(&block) if block
  end

  def method_missing(s, *a, &b)
    send(:define_method, s, &b)
  end
end

