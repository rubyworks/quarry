#!/usr/bin/env ruby

about "Add specified license to project."

usage "--license=<name>"

LICENSES = %w[gpl lgpl mit]

argument(:license) do |val|
  raise ArgumentError, "License name required" unless LICENSES.include?(val.to_s.downcase)
  metadata.license = val.upcase
end

scaffold do
  copy "META/*", metadir
  copy "*", '.', :cd => metadata.license.downcase 
end

