#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class String
  # https://github.com/github/gollum/blob/master/lib/gollum/ruby1.8.rb
  alias :lines :to_a if defined?(RUBY_VERSION) && RUBY_VERSION < '1.9'

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
