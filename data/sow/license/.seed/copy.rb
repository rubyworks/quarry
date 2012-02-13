#!/usr/bin/env ruby

licenses = %w{apache gpl lpgl mit ruby}

argument :license

if data.license && (seed.path + data.license).directory?
  copy '*', :from=>data.license
else
  abort "License not found. Try:\n  " + licenses.join("\n  ")
end

