#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module OY
  module Markup

    class Global < Markup
      self.extension = "*"
      
      def to_html
        parse_result(data)
      end

      def parse_result(result)
        r = result.gsub(/\[{2}([a-zA-Z0-9\/]*?)( [a-zA-Z0-9\/]*?)?\]{2}/){|match|
          url = $1.downcase
          cls = begin
                  r=repos.find_by_fragments(url)
                  raise NotFound if r.kind_of?(WikiDir)
                  "x"
                rescue NotFound
                  "o"
                end
          "<a href='/#{url}' class='oy-link #{cls}'>#{($2 || $1).strip}</a>"
        }
        r
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
