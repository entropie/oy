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

  class << self
    attr_accessor   :default_font
  end

  self.default_font  = :lato
  
  def self.font_list
    {
      :lato          => "Lato:100,100italic,300,300italic,400,400italic,700,700italic,900,900italic",
      :philosopher   => "Philosopher:regular",
      :molengo       => "Molengo:regular",
      :allerta       => "Allerta:regular",
      :"alerta-stencil"    => "Allerta+Stencil:regular",
      :consolas      => "Consolas:regular,italic,bold,bolditalic",
      :"droid sans"  => "Droid+Sans:regular,bold",
      :lobster       => "Lobster:regular"
    }
  end

  def font
    font_identifier = request[:font] || session[:font] || self.class.default_font
    font = self.class.font_list[font_identifier.to_sym]
    session[:font] = font_identifier
    str =  "@import url(//fonts.googleapis.com/css?family=#{font})\n"
    str << "body\n  :font-family \"#{url_decode(font.split(":").first)}\", serif !important"
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
