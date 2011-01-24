#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'lib/oy'

include OY

def create_media_page(path, data=nil, actor=nil, message=nil)
  bmedia = OY::Media.create_bare(path)

  media  = bmedia.create do |pg|
    pg.message = message || "init from polis import"
    pg.data = data
  end
end

def create_wiki_page(path, data=nil, actor=nil, message=nil)
  bwiki = Wiki.create_bare(path)
  wiki = bwiki.create do |pg|
    pg.message = message || "init from polis import"
    pg.data    = data || "h2. index"
    pg.actor   = actor || OY::Actor
  end
end

require 'digest/md5'


OY.path = "/Users/mit/Source/oytest"

dups = []

images = nil
Dir.chdir(path="/Users/mit/Data/polis/htdocs/cache") do
  images = ["png", "jpg", "jpeg", "gif"].map{|ext|
    Dir["**/*.#{ext}"]
  }.flatten.reject{|img| File.basename(img) =~ /^thumb_/}.
    map{|img| File.join(path, img)
  }.map{|img|
    if File.extname(img) == ".jpeg"
      img.gsub(/\.(jpeg)$/, ".jpg")
    else
      img
    end
  }.select{|img|
    begin
      fr = File.read(img)
      md5 = Digest::MD5.hexdigest(fr)
      raise if dups.include?(md5)
      dups << md5
      raise if fr.size <= 640
      true
    rescue
      false
    end
  }
end

def puts(*args)
  Kernel.puts *args
end

require "enumerator"
str = []
i = 0
pg = 0
images.each_slice(5) do |imgg|
  page = "polis/media/page#{pg}.textile"
  pgstr = "h1. Media import <em>Page: #{pg}</em>\n\n"

  if pg != 0
    pgstr << "[[polis/media/page#{pg-1} Previous Page #{pg-1}]] "
  end
  pgstr << " [[polis/media/index Index]] "
  if pg != 40
    pgstr << "[[polis/media/page#{pg+1} Next Page #{pg+1}]] "
  end

  pgstr << "\n\n<ul class='nodisc'>"
  str << "#{page}"
  imgg.each do |img|
    path = "polis_image_%03i#{File.extname(img)}" % i+=1
    create_media_page(path, File.read(img))
    pgstr << "<li><a href='/media/img/#{path}?p=1'><img src='/img/#{path}' /></a><br/><input size='50' type='text' value='/img/#{path}'/></li>\n"
  end
  create_wiki_page(page, pgstr + "</ul>")
  pg+=1
end

str = str.map{|page| "* [[#{page.split(".").first} #{File.basename(page.split(".").first)}]]"}.join("\n")
str = "h1. Media import of polis.ackro.org\n\n" << str

create_wiki_page("polis/media/index.textile", str)


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
