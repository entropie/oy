#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class SpecialController < OYController
  map "/oy/special"

  include OY

  def index
  end

  # gets the full file listing for the entire repos
  def all
    full_page_titles = nil
    full_page_titles = true if request[:titles] == "1"
    Dir.chdir(repos.path) do
      @contents = Dir["**/*.*"]
    end
    @contents.reject!{|c| File.dirname(c) == "media"}
    
    @contents = @contents.map{|content|
      r = repos.find_by_fragments(*content)
      r.parse_body if full_page_titles
      r
    }.sort_by{|c| c.date }.reverse
  end

  # gets all media files for the entire repos
  def media(*fragments)
    unless fragments.empty?
      imgpath = File.join("media/", *fragments)
      @img = repos.find_by_path(imgpath)

      if sha = request[:sha]
        @perma_link_value = sha
        @img = @img.history(sha)
      end
      @size = @img.size
    else
      Dir.chdir(repos.path) do
        @images = Dir["media/**"]
        @images.reject!{|i| File.directory?(i)}
        @images.map!{|i|
          repos.find_by_path(i)
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
