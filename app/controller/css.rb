#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class CSSController < Ramaze::Controller # def ctrl
  map     "/css"
  provide :css, :Sass
  engine :Sass
  trait :sass_options => {
    :style => :expanded,
  } 

  def oy
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
