#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "rubygems"
require "grit"

require "pp"

ReposPath = File.expand_path("~/Source/oytest") 


module OY
  
  Source = File.expand_path(__FILE__)

  Version = [0, 0, 1]

  def path=(str)
    @path = str
  end
  
  def path
    ReposPath || path
  end
  
  def repos
    @repos ||= Repos.new(ReposPath)
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
