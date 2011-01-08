#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


require 'rubygems'
require '../ramaze/lib/ramaze'
require "lib/oy"
require "redcloth"

include OY


task :test do

  t = "h1. Test Index\n\n\nasd\n\n\ndsadsa\n\n\nsadsa\n\n\n\ndsakldsald"

  # page = repos.find_by_fragments("index")
  # page.update do |pg|
  #   pg.message = "lalamessagea  a"
  #   pg.author = "Michael"
  #   pg.data = t << "234 ssdaas 1111 112\nsakdjsakd sasas" << t
  # end
  page = repos.find_by_path("media/MoarTits.jpg")

  p page.path
  begin
    bwiki = Wiki.create_bare("test/a/b/c/../f00.textile")
    wiki = bwiki.create do |pg|
      pg.message = "init las"
      pg.data    = "asd"
    end
  rescue OY::IllegalAccess
    p 2
  end
  
  #p wiki.data
  
end


task :markup do
  pp OY::Markup::Markups[:compare]
  # page = repos.find_by_fragments("index")
  # p page.data
end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
