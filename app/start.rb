#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


require "rubygems"

#require '../../ramaze/lib/ramaze'

require "ramaze"

begin
  require "../lib/oy"
rescue LoadError
  require "oy"
end


require "model/git"

require "redcloth"

controller = %w"oy special media css wiki api".map{ |lib|
  File.join("controller", lib)
}
libs = []

module Innate # :nodoc: All
  class Session
    public :cookie
  end
end

(controller + libs).each{|lib| require lib}


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
