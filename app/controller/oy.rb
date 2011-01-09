#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


class OYController < Ramaze::Controller
  engine :Haml
  
  set_layout_except 'layout'

  IgnoreList = %w'edit create history new compare oy img'

  private

  def create_prefix
    fragments = request.path.split("/")[1..-1]
    if not fragments or fragments.empty?
      return
    elsif fragments.first == "oy"
      return
    elsif IgnoreList.include?(fragments.first)
      fragments.shift
    end
    "#{File.dirname(File.join(*fragments))}/"
  end
  
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
