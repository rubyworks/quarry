require 'sow/manager'
Sow::Manager.instance_eval do
  @bank_folder = Pathname.new(File.expand_path('tmp/bank'))
  @silo_folder = Pathname.new(File.expand_path('tmp/silo'))
end

