# Reap scaffolding.

scaffold 'reap' do

  # Get project name.
  # TODO: What about subselection?
  setup do |args, opts|
    name = args.shift
    #metadata.name = name || directory.basename.to_s.methodize
    abort "Missing argument for project name." unless name
    metadata.name = name
    super(args, opts)
  end

  # Look for any FIX marks in scaffolding.
  report_complete do
    super
    report_fixes
  end

end

