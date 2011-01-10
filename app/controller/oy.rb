#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


class OYController < Ramaze::Controller
  engine :Haml
  
  set_layout_except 'layout'

  IgnoreList = %w'edit create history new compare oy img revert'

  private

  def create_prefix(arr = false, npath = nil)
    fragments = (npath or request.path).split("/")[1..-1]
    fragments ||= []

    fragments.reject!{|f| f == "."}
    
    if fragments.empty? or fragments.first == "oy"
      return arr ? fragments : ''
    elsif IgnoreList.include?(fragments.first)
      return "" if fragments.first == "revert"
      fragments.shift
    end
    if arr then fragments else
      ret = "#{File.dirname(File.join(*fragments))}/"
      return '' if ret == "./"
      ret
    end
  end

  def page_prefix
    create_prefix(true)[0..-2].map{|prfx| "#{prfx.capitalize} &gt; "}.join
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
