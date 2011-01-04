#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


require "rubygems"

require '../../ramaze/lib/ramaze'

require "../lib/oy"

require "model/git"


require "redcloth"

controller = %w"oy special css wiki".map{ |lib|
  File.join("controller", lib)
}
libs = []

class Innate::Session
  public :cookie
end
(controller + libs).each{|lib| require lib}


if `hostname`.strip == "io"
  Ramaze.start(:host => "kommunism.us",
               :port => 8200)
else
  Ramaze.start(:host => "localhost",
               :port => 8200)

end




=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
