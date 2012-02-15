#utilize 'pom'

#ensure_empty('PROFILE', 'VERSION')

#argument :name, :default => File.basename(output).chomp('/')

data.name ||= File.basename(output).chomp('/')

#let :name, destname

raise "Name is required."         unless data.name
raise "Name must be single word." unless data.name =~ /\w+/

#metadata.name    = name  # TODO
data.title   = data.title   || data.name.capitalize
data.contact = data.contact || ENV['EMAIL']

copy "**/*", :render=>'erb'
copy "bin/*", :mode=>0744

# TODO: Should we protect certain files from ever being overwrite?
#skip('PROFILE', 'VERSION')

