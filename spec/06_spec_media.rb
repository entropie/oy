#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "helper"

describe OY::Media do
  it "Should #exist?" do
    page = repos.find_by_path("media/ass.jpg")
    page.exist?.should == true
    page.class.should == OY::Media
  end

  it "Should have a #history" do
    page = repos.find_by_path("media/banner.gif")
    page.exist?.should == true
    page.has_parent?.should == true
  end

  it "Should have an #identifier" do
    page = repos.find_by_path("media/banner.gif")
    page.identifier.should == "banner"
  end

  it "Should have a #media_url" do
    page = repos.find_by_path("media/banner.gif")
    page.media_url.should == "/media/img/banner.gif"
  end

  it "Should have a #media_url(sha)" do
    page = repos.find_by_path("media/banner.gif")
    page.media_url(true).should == "/media/img/banner.gif?sha=#{page.sha}"
  end

  it "Should have a #permalink" do
    page = repos.find_by_path("media/banner.gif")
    page.permalink.should == "/oy/special/media/banner.gif"
  end

  it "Should have a #permalink(sha)" do
    page = repos.find_by_path("media/banner.gif")
    page.permalink(true).should == "/oy/special/media/banner.gif?sha=#{page.sha}"
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
