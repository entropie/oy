#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'rubygems'  
require "redcloth"

require '../ramaze/lib/ramaze'

$LOAD_PATH.unshift(__DIR__)  

require "lib/oy"
require "app/model/git"

controller = %w"oy special media css wiki".map{ |lib|
  File.join("app/controller", lib)
}

Ramaze::Global.sourcereload = false  
Ramaze::Global.sessions = true  
Ramaze::Log.ignored_tags = [:debug, :info]


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
