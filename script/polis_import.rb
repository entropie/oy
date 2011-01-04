#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'yaml'
require 'pp'
require '../backbite.git/lib/backbite'#
require 'readline'
require 'lib/oy'

include OY

tlog = Backbite.register[:polis]

dirs = Dir['/Users/mit/Data/blog/spool/**.yaml'] +
  Dir['/Users/mit/Data/blog/archive/*/*/**.yaml']


a=dirs.grep(/\.yaml/).map do |y|
  co = nil
  cos = File.basename(y).split("-")
  if cos.first =~ /^\d+$/
    co = cos[1]
  else
    co = cos[0]
  end
  co = co.to_sym
  [co,YAML::load(File.open(y).readlines.join)]
end.uniq

fooblog = []

a.each do |name, cont|
  c = cont
  case name
  when :blog
    pagedata = "h1. %s\n\n%s" % [cont[:input_topic], cont[:input_body]]

    authorcomp = cont[:plugin_author] || "Michael Trommer <mictro@gmail.com>"
    name = authorcomp.split("<").first.strip
    email = authorcomp[/<(.*)>/, 1]
    actor = Grit::Actor.new(name, email)
    
    topic = cont[:input_topic]
    topic = topic.gsub(/\W/, '')

    bwiki = Wiki.create_bare("oldblog/#{topic.downcase}.textile")
    wiki = bwiki.create do |pg|
      pg.message = "initial for #{topic}"
      pg.data    = pagedata
      pg.actor   = actor
    end
    fooblog.push([bwiki, topic, cont[:plugin_date]])
  when :ruby, :shell, :wise, :irc, :btw
    next
  else
    next
  end
  
end

pagedata = "h1. Index for import of blog.ackro.org\n\n"
fooblog.each do |fblog, topic, date|
  name = File.basename(fblog.path).split(".").first.capitalize
  pagedata << "* [[%s %s]] <small><em>Origin Date:</em> %s</small>\n" % [fblog.path.split(".").first, topic, date]
end

bwiki = Wiki.create_bare("oldblog/index.textile")
wiki = bwiki.create do |pg|
  pg.message = "initial for index"
  pg.data    = pagedata
  pg.actor   = Grit::Actor.new("Michael Trommer", "mictro@gmail.com")
end
=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
