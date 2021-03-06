#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module OY

  module Markup

    class Redcloth < Markup

      self.extension = "textile"

      def to_html
        redcloth = RedCloth.new(data)
        redcloth.hard_breaks = false
        redcloth.to_html
      end

    end
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
