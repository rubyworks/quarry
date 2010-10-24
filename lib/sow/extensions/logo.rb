#--
# The Loge extensions provide methods for utilizing any logo file with in
# the destination directory, and a means for grabing a logo image from the
# net if none is found.
#++

module Sow

  class Sowfile

    # Fallback logo file (if all else fails).
    LOGO = "assets/logo.png"

    # Return the path to the logo file, which is the first file
    # found named `logo.*`. If not found, pull a randomly searched
    # image from the Internet for a logo.
    #
    # Currently the search feature uses BOSSMan to pull from Yahoo
    # Image Search, which requires a Yahoo App ID. Of course, it 
    # would be better if it were generic, but we do what we can.
    def logo(options={})
      @logo ||= (
        if file = output.glob_relative('**/logo.*').first
          file #.relative_path_from(output)
        else
          keyword   = options[:keyword]
          directory = options[:directory]
          keyword ||= (metadata.search || metadata.title || metadata.name)
          logo_search(keyword, directory)
        end
      )
    end

    # Yahoo Application ID used by Bossman for finding a logo.
    # Yahoo Application ID is looked for in metadata as `yid`,
    # then `$HOME/.config/yahoo.id`, and failing this it looks
    # for 'YAHOO_ID' environment variable.
    def yahoo_id
      @yahoo_id ||= (
        metadata.yid || (
          home = Pathname.new(File.expand_path('~'))
          file = home.glob('.config/yahoo.id').first unless file
          file ? file.read.strip : ENV['YAHOO_ID']
        )
      )
    end

    # Logo search using Bossman.
    def logo_search(keyword, dir='assets')
      return LOGO unless require_bossman
      return LOGO unless yahoo_id
      keyword = keyword.to_s
      begin
        BOSSMan.application_id = yahoo_id #<Your Application ID>
        boss = BOSSMan::Search.images(keyword, {:dimensions => "small"})
        if boss.count == "0"
          boss = BOSSMan::Search.images("clipart", {:dimensions => "small"})
        end
        url = boss.results[rand(boss.results.size)].url
        ext = File.extname(url)
        dir = output + dir
        out = dir + "logo#{ext}"
        fu.mkdir_p(dir) unless dir.exist?
        open(url) do |i|
          open(out, 'wb') do |o|
            o << i.read
          end
        end
        out.to_s
      rescue
        LOGO
      end
    end

    # Require Bossman library for Yahoo image search.
    def require_bossman
      begin
        require 'bossman'
        require 'open-uri'
        true
      rescue LoadError
        nil
      end
    end

  end

end

