#!/usr/bin/env ruby

help "Add specified license to project."

usage "license [options] <license>"

LICENSES = %w[gpl lgpl mit]

argument(:license) do |val|
  raise ArgumentError, "License name required" unless LICENSES.include?(val.to_s.downcase)
  metadata.license = val.upcase
end

manifest do
  copy "META/*", metadir
  copy "*", '.', :cd => argv[:license].downcase 
end

