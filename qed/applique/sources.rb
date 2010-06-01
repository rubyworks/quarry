When /Given that we have Sow sources setup/ do
  require 'sow/session'
  Sow::Manager::SOURCE_DIRS.replace([Dir.tmpdir + '/sow/sources'])
end

