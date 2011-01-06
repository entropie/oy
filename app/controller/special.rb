#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class SpecialController < OYController
  map "/oy/special"

  include OY

  def index
  end

  def all
    Dir.chdir(repos.path) do
      @contents = Dir["**/*.textile"]
    end
    @contents = @contents.map{|content|
      repos.find_by_fragments(*content)
    }.sort_by{|c| c.date}.reverse
  end

  def media(*fragments)
    unless fragments.empty?
      @img = File.join("/media/", *fragments)
      @size = File.size(File.join(repos.path, "media", *fragments[1..-1]))
    else
      Dir.chdir(repos.path) do
        @images = Dir["media/**"]
        @images.reject!{|i| File.directory?(i)}
        @images.map!{|i| "/media/img/#{i.split('/')[1..-1].join('/')}"}
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
