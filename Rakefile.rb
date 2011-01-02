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
  # p repos.commits
  # 
  c = repos.git.commits
  # p (repos.tree/"kekelala").data
  # p (repos.tree/"index.textile").data
  page = repos.find_by_fragments("test", "index")
  puts 
  pp page.data
  pp page.author
  pp page.date
  pp page.message
  pp page.extension
  page = repos.find_by_fragments("index")
  puts 
  pp page.data
  pp page.author
  pp page.date
  pp page.message
  pp page.extension
  
end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
