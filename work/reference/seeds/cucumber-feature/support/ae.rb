# Use Assertive Expressive
begin
  require 'ae'
  require 'ae/expect'
  require 'ae/should'
rescue LoadError
  # no AE
end
