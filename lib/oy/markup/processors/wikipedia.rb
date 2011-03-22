#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "open-uri"

class OY::Markup::Global::Processors

  class Wikipedia < Processor

    def process_tag(tag)
      parts = tag.split(" ")
      embed = desc = lang = nil
      if parts.size == 2 and parts.first == "wp" and parts.last =~ /http:\/\/(\w+)\.wikipedia\.org\/wiki\/(.*)/i
        lang = $1
        desc = $2
      end
      return false unless desc
      @lang, @desc = lang, desc
      to_html
    end

    def url
      @url ||= "http://#{@lang}.wikipedia.org/wiki/#{@desc}"
    end

    def url_to(wp_page)
      "http://#{@lang}.wikipedia.org/wiki/#{wp_page}"
    end

    def move_toc(body)
      toc = OY::Markup::Nokogiri::TOC.dup
      wp_toc = body.at_css("#toc")
      body.at_css("#toc").remove
      toc_content = wp_toc.at_css("ul:first")
      toc.at_css("ul").replace(toc_content)
      body.children.before(toc)
    end

    def fix_relative_links(body)
      body.css("a").each do |link|
        href = link["href"]
        if href =~ /\/wiki\/(.*)/
          link["href"] = url_to($1)
        end
      end
    end

    def read_article
      doc = ::Nokogiri::HTML.parse(open(url), nil, "UTF-8")
      title = doc.at_css("#firstHeading")
      body  = doc.at_css("#bodyContent")

      ['#siteSub', '#contentSub', '#catlinks', '#jump-to-nav', '.editsection'].each do |ele|
        body.css(ele).remove
      end
      move_toc(body)
      fix_relative_links(body)

      [title, "<notextile>%s</notextile>" % body.to_html]
    end

    def to_html
      read_article.join
    end
  end

  register Wikipedia

end



=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
