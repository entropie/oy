#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "rubygems"
require "grit"
require "ostruct"
require "redcloth"
require "nokogiri"
require "json"

require "pp"

ReposPath = File.expand_path("~/Source/oytest") 

module OY
  
  Source  = File.dirname(File.dirname(File.expand_path(__FILE__)))

  Actor   = Grit::Actor.new("Anonymous", "anonym@o.us")
  
  $: << File.join(Source, "lib/oy")
  $: << File.join(Source, "app")


  Version = [0, 0, 1]

  def api(host = nil)
    @api ||= Api.new(host)
  end
  module_function :api
  
  def path=(str)
    @path = str
  end
  module_function "path="
    
  def path
    @path || ReposPath
  end
  module_function :path  
  
  def repos(with_git = true)
    if with_git
      @repos = Repos.new(OY.path)
    else
      @repos = VirtualRepos.new(OY.path)
    end

  end
  module_function :repos

  require "model/git"
  require "blob_entry.rb"
  require "git_access.rb"

  require "api.rb"

  require "repos"
  require "exceptions.rb"
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
