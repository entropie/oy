#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "rubygems"
require "grit"
require "ostruct"

require "pp"

ReposPath = File.expand_path("~/Source/oytest") 

module OY
  
  Source  = File.dirname(File.dirname(File.expand_path(__FILE__)))

  Actor   = Grit::Actor.new("Anonymous", "anonym@o.us")
  
  $: << File.join(Source, "lib/oy")
  $: << File.join(Source, "app")


  Version = [0, 0, 1]

  def path=(str)
    @path = str
  end
  module_function "path="
    
  def path
    ReposPath || path
  end
  module_function :path  
  
  def repos
      @repos ||= Repos.new(ReposPath)
  end
  module_function :repos

  require "model/git"
  require "blob_entry.rb"
  require "git_access.rb"

  require "markup"
end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
