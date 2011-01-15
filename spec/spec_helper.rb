#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "rubygems"
require "rspec"

require "lib/oy"

include OY
OY.path = "/tmp/testrepos"

def puts(*args)
end

def r(*args)
  nargs = args.empty? ? ["test", "spec"] : args
  repos.find_by_fragments(*nargs)
end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
