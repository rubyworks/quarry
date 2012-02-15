# TODO: add starter cucumber.yaml config file
# TODO: Perhaps add automatic detection of location of features?

argument :feature #, :default => 'new'
argument :directory

let :directory, 'features'  # TODO: way to make this argument() option?

abort "feature name is required" unless data.feature

if (output + data.directory).exist?
  copy "___feature___.feature", data.directory, :from=>'features'
else
  copy "**/*", data.directory, :from=>'features'
end

#select :setup do
#  argument :directory, :default=>'features'
#  copy "**/*", data.directory, :from=>'features'
#end

