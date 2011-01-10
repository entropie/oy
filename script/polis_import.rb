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

dirs = Dir['/Users/mit/Data/polis/spool/**.yaml'] +
  Dir['/Users/mit/Data/polis/archive/*/*/**.yaml']


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

target = :image

a.each do |name, cont|
  c = cont
  case name
  when :image
    #fooblog << {:date => c[:plugin_date], :text => c[:input_text]}
    fooblog << c[:plugin_img]
  when :nut
  else
    next
    #  when :blog1
    # pagedata = "h1. %s\n\n%s" % [cont[:input_topic], cont[:input_body]]

    # authorcomp = cont[:plugin_author] || "Michael Trommer <mictro@gmail.com>"
    # name = authorcomp.split("<").first.strip
    # email = authorcomp[/<(.*)>/, 1]
    # actor = Grit::Actor.new(name, email)
    
    # topic = cont[:input_topic]
    # topic = topic.gsub(/\W/, '')

    # bwiki = Wiki.create_bare("oldblog/#{topic.downcase}.textile")
    # wiki = bwiki.create do |pg|
    #   pg.message = "initial for #{topic}"
    #   pg.data    = pagedata
    #   pg.actor   = actor
    # end
    # fooblog.push([bwiki, topic, cont[:plugin_date]])
    # when :ruby, :shell, :wise, :irc, :btw
    #   next
    # else
    #   next
  end
end

case target
when :image
  require 'open-uri'
  fooblog.reject!{|i| i !~ /^http/}

  fooblog.map!{|i|
    begin
      i
    rescue OpenURI::HTTPError, SocketError, URI::InvalidURIError
      nil
    end
  }.compact
  file = File.open("/tmp/img_list.txt", 'w+') do |fc|
    fc.write(fooblog.join("\n"))
  end

  pagestr = "h1. Imported Images from polis.ackro.org\n\n"
  
  
  #pp fooblog
when :nut
  nameSpace = "polis"
  hash = Hash.new{|h,k| h[k] = []}

  str = ''
  lyear = nil
  fooblog.sort_by{|c| c[:date]}.reverse.each do |b|
    if not lyear or lyear != b[:date].year
      lyear = b[:date].year
      hash[lyear] << "\nh1. Index for <em>nut</em> #{b[:date].year}, from polis.ackro.org\n\n"
    end
    hash[lyear] << " * #{b[:text].gsub(/\n/, '')} <small>Origin Date: <span class='date'>#{b[:date]}</span></small>"
  end


  nut_index_page = File.join(nameSpace, "nut", "index.textile")
  hash.sort_by{|year, conts| year}.reverse.each do |year, conts|
    file = File.join(nameSpace, "nut", "index#{year}.textile")

    page = begin
             Wiki.create_bare(file)
           rescue AlreadyExist
             repos.find_by_fragments(*file.split("/"))
           end
    pagestr = conts.join("\n")
    page.update do |pg|
      pg.message = "Initial for nut section"
      pg.actor   = Grit::Actor.new("Michael Trommer", "mictro@gmail.com")
      pg.data    = pagestr
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
