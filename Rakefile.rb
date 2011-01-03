#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


require 'rubygems'
require '../ramaze/lib/ramaze'
require "lib/oy"
require "app/model/git"
require "redcloth"

include OY


task :test do


  page = repos.find_by_fragments("index")

  p page.sha
  p page.link(:version)
  h=page.history.first
  p h.link(:version)
  h=h.history.first
  p h.link(:version)
  h=h.history.first
  p h.link(:version)

  
  # p page.sha
  # p page.link(:version)
  # p page = page.history.first
  # p page.sha
  # p page.link(:version)

  # puts
  # pp page.history.first
  # puts 
  # pp page.data
  # pp page.author
  # pp page.date
  # pp page.message
  # pp page.extension

  # pp page.repos

  # puts

  # page.history.each do |cm|
  #   pp cm
  # end
  # pp page.path

  # pp page.has_parent?
  
  # ga = GitAccess.new
  # p ga.blob("7bb3f5590a1894613a80a11b62a47b0b33f14c90")
  #p ga.blob(page.id).class
  # p page.repos
  # p page.repos.git
  # p page.repos.git.git
  
end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
