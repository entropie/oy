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

  def upload
  end

  def media(*fragments)
    @img = File.join("/media/img/", *fragments)
    p @img
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
