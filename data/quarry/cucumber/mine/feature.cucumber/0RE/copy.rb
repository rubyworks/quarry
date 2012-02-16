argument :feature_name
argument :features_directory

# if directory is not set by argument, then try to figure it out,
# else fallback to `features`.
let :features_directory do
  file = output.glob('*/*.feature').first
  file ? File.dirname(file) : 'features'
end

raise "Feature name is a required argument." unless feature_name

copy 'features', feature_directory

