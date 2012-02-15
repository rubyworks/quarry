case config.markup
when 'textile'
  render 'README.tt.erb', 'README.textile'
when 'tt'
  render 'README.tt.erb'
when 'rdoc'
  render 'README.rdoc.erb'
when 'markdown'
  render 'README.md.erb', 'README.markdown'
when 'md'
  render 'README.md.erb'
else
  render 'README.rdoc.erb'  # or markdown ?
end

