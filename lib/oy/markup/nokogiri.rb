#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module OY
  module Markup

    class Nokogiri < Markup
      self.extension = "xml"
      
      def to_html
        @doc = ::Nokogiri::HTML::DocumentFragment.parse(data)
        parse_result
        @doc.to_html
      end

      def parse_result
        title = @doc.css(":first").first
        if title and title.name == "h1"
          @wiki.html_title = title.content
          title.remove
        end
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
