#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "helper"

describe OY::VirtualRepos do
  it "Should #exist?" do
    page = repos(false).find_by_path("media/ass.jpg")
    page.exist?.should == true
    page.class.should == OY::VirtualRepos
  end

  ["commit", "permalink", "date", "author", "has_parent?", "link"].each do |meth|
    it "Should respond to ##{meth}" do
      page = repos(false).find_by_path("media/ass.jpg")
      page.send(meth.to_sym).should == page.to_commit.send(meth.to_sym)
    end
  end
  it "Should have the right extension" do
    page = repos(false).find_by_path("media/ass.jpg")
    page.extension == "jpg"
  end

  it "Should have a history" do
    page = repos(false).find_by_path("media/banner.gif")
    page.extension == "gif"
    page.has_parent?.should == true
    page.history.size.should == 1
  end

  it "Should respond to #is_media?" do
    page = repos.find_by_path("media/banner.gif")
    page.is_media?.should == true
  end

  it "Should respond (physically) to #is_media?" do
    page = repos(false).find_by_path("media/banner.gif")
    page.is_media?.should == true
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
