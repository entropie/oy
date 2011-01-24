#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module OY
  module Markup

    class Nokogiri < Markup
      self.extension = "xml"

      def self.is_virtual?
        true
      end

      def make_toc
        toc = ::Nokogiri::HTML::DocumentFragment.parse "<div id='oy-toc'><h2>Table Of Contents</h2><ul></ul></div>"
        i = 0
        @doc.children.each do |child|
          if child.name =~ /^h[123456]$/
            child["id"] = "topic#{i+=1}"
            li = ::Nokogiri::XML::Node.new("li", toc)
            a  = ::Nokogiri::XML::Node.new("a", toc)
            a["href"] = "##{child["id"]}"
            a.content = child.text
            a.parent = li
            li['class'] = "#{child.name}"
            toc.at_css("ul").add_child(li)
          end
        end
        @doc.children.before toc
      rescue
        puts $!
        ''
      end
      
      def to_html
        @doc = ::Nokogiri::HTML::DocumentFragment.parse(data)
        parse_result
        make_toc
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
