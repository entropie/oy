#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "spec_helper"
include OY

def spec_create_wiki_page(path, data=nil, actor=nil, message=nil)
  bwiki = Wiki.create_bare(path)
  wiki = bwiki.create do |pg|
    pg.message = message || "init from spec"
    pg.data    = data || "h2. index"
    pg.actor   = actor || OY::Actor
  end
end


# describe "Unicode Pages" do
#   context "create unicode page" do

#     it "should be possible to create a unicode page" do
#       p spec_create_wiki_page("test/ěĕėƒĝğġģĥ.textile", "foo")
#     end

#     it "should have a clean index" do
#       Dir.chdir(OY.path) do
#         puts
#         puts "-"*60
#         puts "\n#{`git status`}"
#         puts "-"*60        
#         `git status`.split("\n").size.should == 2
#       end
#     end
#   end
  
# end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
