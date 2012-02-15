#!/usr/bin/env ruby

licenses = %w{apache gpl lpgl mit ruby}

argument :license

if data.license && (template.path + data.license).directory?
  copy '*', :from=>data.license
else
  abort "License not found -- #{data.license}. Try:\n  " + licenses.join("\n  ")
end

