#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


require "rubygems"
require "ramaze"
require "redcloth"

begin
  require "../lib/oy"
rescue LoadError
  require "oy"
end


require "model/git"

controller = %w"oy special media css wiki api".map{ |lib|
  File.join("controller", lib)
}
libs = []

(controller + libs).each{|lib| require lib}


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
