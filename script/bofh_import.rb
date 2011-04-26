#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "lib/oy"
require "nokogiri"
require "open-uri"

URL = "http://www.nyms.de/bofh.html"

chapters = Hash.new{|h,k| h[k] = []}

doc = Nokogiri::HTML(open(URL)).at_css("body")

3.times{
  doc.css("p:nth-child(3)").remove
}
doc.css("hr:first").remove


t = 1

doc.children.each do |ele|
  if ele.name == "hr"
    t += 1
    next
  elsif t > 0 and not ele.text.strip.empty?
    next if ele.text.split(//).all? {|c| c == "-"}
    ele.inner_html = ele.inner_html.gsub(/<br>/, " ")
    chapters[t] << ele.text
  end
end

file = File.expand_path("~/Tmp/bofh")
chapters.sort_by{|k, v| k}.each{|k,v| v.each{|para| para.gsub!("\r\n", " ")} }.each do |k, v|
  chapter_file = "#{file}_#{"%02i" % k}.textile"

  topic = v.shift
  fc = v.map{|c| "\n#{c}\n" }.join.strip

  puts chapter_file
  File.open(chapter_file, 'w+'){|fp|
    fp.puts "h1. #{topic}\n\n#{fc}"
  }
end

=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
