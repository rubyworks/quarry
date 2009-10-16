module Sow::Plugins

  # Readme2webpage Sow Generator
  #
  # Generates a basic website based on a README
  # file. It does this by sectioning the README
  # into tabs based on <h2>'s.

  class Readme2Web < Script

    output do
      find = '{site,web,website,www}'
      project.root.glob_first(find) || project.root + 'web'
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

    #
    def index
      attr :header
      attr :body
      attr :sections

      def setup
        # create html, sections and header
        readme = project.root.glob('readme{,.txt}', :casefold).first

        abort "No readme file found." unless readme

        require 'rdoc/markup/simple_markup'
        require 'rdoc/markup/simple_markup/to_html'

        m = SM::SimpleMarkup.new
        h = SM::ToHtml.new

        html = m.convert(File.read(readme), h)

        i = html.index('<h2>')

        header = html[0...i]
        html[0...i] = ''

        sections = []

        html.gsub!(/<h2>(.*?)<\/h2>/) do |m|
          label = $1
          ident = label.gsub(/\s+/, '_').downcase
          sections << [ident, label]
          %[</div><div class="section" id="section_#{ident}"><h2>#{label}</h2>]
        end
        html.sub!('</div><div class="section"', '<div class="section"')
        html << '</div>'

        @body = html
        @header = header
        @sections = sections
      end
    end

  end

end

