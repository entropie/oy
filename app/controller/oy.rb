#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


class OYController < Ramaze::Controller
  engine :Haml
  
  set_layout_except 'layout'


  private

  def time_to_s(t)
    t.strftime("%d-%b-%y")
  end
end




=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
