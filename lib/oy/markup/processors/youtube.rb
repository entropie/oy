#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "open-uri"

class OY::Markup::Global::Processors

  class Youtube < Processor

    def process_tag(tag)
      parts = tag.split(" ")
      embed = ytid = nil
      if parts.size == 1 and parts.join =~ /youtube\.com\/watch\?v=(.*)/
        ytid = $1
      elsif parts.size >= 2
        if parts.first =~ /^(youtube|yt)$/
          ytid = parts[1]
          if parts.size == 3 and parts.last == "embed"
            embed = true
          end
        end
      end
      return false unless ytid
      @ytid = ytid
      to_html(embed)
    end

    def url
      @url ||= "http://youtube.com/watch?v=#{@ytid}"
    end


    def get_title
      @title ||= ::Nokogiri::HTML.parse(open(url)).at_css("#eow-title").text.strip
    rescue
      p $!
      '<no title>'
    end

    def to_html(embed = nil)
      if not embed
        "<p class='oy-youtube'><a href='#{url}'><img alt='Youtube.com Video: ' src='http://i.ytimg.com/vi/#{@ytid}/0.jpg'/></a></p>"
      else
        %Q'<p class="oy-youtube-i"><iframe title="YouTube video player" width="480" height="390" src="http://www.youtube.com/embed/#{@ytid}" frameborder="0" allowfullscreen></iframe>'
      end
    end
  end

  register Youtube

end

=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
