#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class String

  def upcase
    Unicode.upcase(self)
  end

  def downcase
    Unicode.downcase(self)
  end

  def capitalize
    Unicode.capitalize(self)
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
