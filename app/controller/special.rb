#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class SpecialController < OYController
  map "/oy/special"

  include OY

  helper :cache

  def pageslide(ident)

    @wiki, @time = find_by_fragments(*ident.split("/"))
    @history = @wiki.history[0..9]

    @toc = ::Nokogiri::HTML::DocumentFragment.parse(@wiki.data).at_css("#oy-toc").to_html rescue ""
  end

  def index
    @pages = WikiIndex.directories
    @subpages = {}
    @pages.each{|dir| @subpages[dir.path] = dir.pages.sort_by{|p| p.title}}
  end

  def list_fonts
    @fonts = CSSController.font_list
  end


  # gets the full file listing for the entire repos
  #
  # FIXME:
  def all
    full_page_titles = nil
    full_page_titles = true if request[:titles] == "1"
    Dir.chdir(repos.path) do
      @contents = Dir["**/*.*"]
    end

    @contents.reject!{|c|
      File.dirname(c) == "media" or File.dirname(c)[0] == ?_ or c =~ /\.locked$/
    }

    @contents = @contents.map{|content|
      begin
        frags = content.split("/")
        wiki, _, _ = find_by_fragments(*frags)
        wiki
      rescue NotFound
        nil
      end
    }.compact.sort_by{|c| c.date }.reverse
  end

  # gets all media files for the entire repos
  def media(*fragments)
    unless fragments.empty?
      imgpath = File.join("media/", *fragments)
      @img, t, cached = find_by_path(imgpath)

      if sha = request[:sha]
        @perma_link_value = sha
        @img = @img.history(sha)
      end
      @size = @img.size
    else
      Dir.chdir(repos.path) do
        @images = Dir["media/**"]
        @images.reject!{|i| File.directory?(i) or i =~ /\.locked$/}
        @images.map!{|i|
          img, t, cached = find_by_path(i)
          img
        }
      end
    end
  end

end



=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
