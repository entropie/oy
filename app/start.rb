#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


require "rubygems"

begin
  require "../lib/oy"
rescue LoadError
  require "oy"
end


# ramaze & innate
$: << File.join(OY::Source, "../innate/lib")
$: << File.join(OY::Source, "../ramaze/lib")

require "innate"
require "ramaze"


Dir["#{OY::Source}/lib/oy/middleware/*.rb"].each do |mw|
  require mw
end

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
