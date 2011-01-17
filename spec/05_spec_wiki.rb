#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "spec_helper"

describe OY::Wiki do

  context "default" do
    
    it "should be normalize a path" do
      Wiki.normalize_path("/foo/bar/baz").should == "foo/bar/baz"
      Wiki.normalize_path("foo/bar/baz").should == "foo/bar/baz"      
    end
  end
  
  it "Should exist" do
    page = repos.find_by_fragments("index")
    page.exist?.should == true
  end

  it "Should have some Files" do
    repos.find_by_fragments("index").class.should == Wiki
    repos.find_by_fragments("foo").class.should == Wiki
    repos.find_by_fragments("test", "index").class.should == Wiki
    repos.find_by_fragments("test", "foo").class.should == Wiki
    repos.find_by_fragments("lala").class.should == Wiki    
  end

  it "Should be possible to access the history" do
    page = repos.find_by_fragments("index")
    page.history.size.should == 1
  end

  it "Should have the sha of the commit" do
    page = repos.find_by_fragments("index")
    page.sha.should == page.commit.sha
  end

  it "#self.parent.sha should == #history.first.sha" do
    page = repos.find_by_fragments("index")
    page.parent.sha.should == page.history.first.sha
  end

  it "Should have an ident" do
    page = repos.find_by_fragments("index")
    page.ident.should == "index"

    page = repos.find_by_fragments("test", "foo")
    page.ident.should == "test/foo"
  end

  it "Should have some attributes (#blob => Grit::Blob)" do
    page = repos.find_by_fragments("index")
    page.blob.class.should == Grit::Blob
  end

  it "Should have some attributes (#commit => Grit::Commit)" do
    page = repos.find_by_fragments("index")
    page.commit.class.should == Grit::Commit
  end

  it "Should have some attributes (#path => String)" do
    page = repos.find_by_fragments("index")
    page.path.class.should == String
    page.path.should == "index.textile"
  end

  it "Should have some attributes (#repos => Repos)" do
    page = repos.find_by_fragments("index")
    page.repos.path.should == repos.path
  end

  it "Should have some attributes (#identifier => String)" do
    page = repos.find_by_fragments("index")
    page.identifier.should == "index"
  end

  it "Should have some attributes (#permalink => String)" do
    page = repos.find_by_fragments("index")
    page.permalink.should == "/#{page.ident}?sha=#{page.sha}"
  end

  it "Should have a link(:perma)" do
    page = repos.find_by_fragments("index")
    page.link(:perma).should == "/#{page.ident}?sha=#{page.sha}"
  end

  it "Should have a link(:edit)" do
    page = repos.find_by_fragments("index")
    page.link(:edit).should == "/edit/index"
  end

  it "Should have a link(:version)" do
    page = repos.find_by_fragments("index")
    page.link(:version).should == "/#{page.ident}?sha=#{page.parent.sha}"
  end

  it "Should have a link(:history)" do
    page = repos.find_by_fragments("index")
    page.link(:history).should == "/history/#{page.ident}"
  end

  it "Should have a link(:compare)" do
    page = repos.find_by_fragments("index")
    page.link(:compare).should == "/compare/#{page.sha}/#{page.history.first.sha}/#{page.ident}"
  end

  it "Should have a link" do
    page = repos.find_by_fragments("index")
    page.link.should == "/#{page.ident}"
  end
  
  it "Should have a #parent" do
    page = repos.find_by_fragments("index")
    page.parent.class.should == Wiki
    page.history.first.class.should == page.parent.class
  end

  it "Should have a #ref" do
    page = repos.find_by_fragments("index")
    page.ref.should == page.sha[0..7]
  end

  it "Should have a #extension" do
    page = repos.find_by_fragments("index")
    page.extension.should == "textile"
  end

  it "Should have a #author" do
    page = repos.find_by_fragments("index")
    page.author.should == "Anonymous"
  end

  it "Should have a #message" do
    page = repos.find_by_fragments("index")
    page.message.should == "update from spec"
  end
  
  it "Should have a #history" do
    page = repos.find_by_fragments("index")
    page.history.first.class.should == Wiki
  end

  it "Should apply a markup on #data" do
    page = repos.find_by_fragments("index")
    page.data.should =~ /^<h2>index<\/h2>/
  end

  it "Should respond tp #page_name" do
    page = repos.find_by_fragments("index")
    page.page_filename.should == "index.textile"
  end

  it "Should be possible to create a #create_bare" do
    Wiki.create_bare("notexist").class.should == Wiki
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
