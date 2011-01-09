#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'rubygems'
require "spec/spec_helper"

#OY.path = File.join(OY::Source, "/tmp/testrepos")
include OY

def spec_create_wiki_page(path, data=nil, actor=nil, message=nil)
  bwiki = Wiki.create_bare(path)
  wiki = bwiki.create do |pg|
    pg.message = message || "init from spec"
    pg.data    = data || "h2. index"
    pg.actor   = actor || OY::Actor
  end
end

def spec_update_wiki_page(path, data=nil, actor=nil, message=nil)
  page = repos.find_by_fragments(*path.split("/"))
  page.update do |pg|
    pg.message = message || "update from spec"
    pg.data    = data || "h2. index\n\nlalala"
    pg.actor   = actor || OY::Actor
  end
end

def spec_create_media_page(path, data=nil, actor=nil, message=nil)
  bmedia = OY::Media.create_bare(path)

  filec = nil
  Dir.chdir("spec/spec_data") do
    filec = File.read(path)
  end

  media  = bmedia.create do |pg|
    pg.message = message || "init from spec"
    pg.data = filec
  end
end

def spec_update_media_page(path, npath, data=nil, actor=nil, message=nil)
  bmedia = OY::Media.create_bare(path)

  filec = nil
  Dir.chdir("spec/spec_data") do
    filec = File.read(npath)
  end

  media  = bmedia.create do |pg|
    pg.message = message || "update from spec"
    pg.data = filec
  end
end


spec_create_wiki_page "index.textile"
spec_update_wiki_page "index.textile"

spec_create_wiki_page "foo.textile"

spec_create_wiki_page "test/index.textile"

spec_create_wiki_page "test/foo.textile"

spec_create_wiki_page "bar/test.textile"


spec_create_media_page "ass.jpg"
spec_create_media_page "banner.gif"
spec_update_media_page "banner.gif", "ass.jpg"


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
