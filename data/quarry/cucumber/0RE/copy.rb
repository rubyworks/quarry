# TODO: add starter cucumber.yaml config file

argument :features_directory

# if directory is not set by argument, then try to figure it out,
# else fallback to `features`.
let :features_directory do
  file = output.glob('*/*.feature').first
  file ? File.dirname(file) : 'features'
end

copy "mine/*", :verbatim=>true
copy "features", features_directory

