#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "lib/oy.rb"

Dir["spec/*.rb"].each do |specfile|
  unless File.basename(specfile) =~ /^[0-9][0-9]/
    next
  end
  puts `rspec -f d #{specfile}`.split("\n")[0..-3].join("\n")
end



=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
