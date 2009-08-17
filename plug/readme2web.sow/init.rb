# Readme2web Sow Generator
#
# Generates a basic website based on a README
# file. It does this by sectioning the README
# into tabs based on <h2>'s.

help "Generate a website from a README file."

output do
  find = '{website,web,site,www}'
  if project.admin == project.root
    project.root.glob_first(find) || project.root + 'web'
  else
    project.admin.glob_first(find) ||
    project.root.glob_first(find)  ||
    project.admin + 'web'
  end
end

manifest do
  # NOTE: Might we do per template parts?
  #template('index.html.erb', web, :body=>html)

  # NOTE: what about verbatim?
  #verbatim('_assets')

  copy('index.html', '.')
  copy('assets',     '.')
end

# overwrite : true?

