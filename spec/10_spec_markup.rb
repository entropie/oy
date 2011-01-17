#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "spec_helper"

describe OY::Markup do

  context "default" do

    it "Should have a default extension (textile)" do
      OY::Markup.default_extension.should == "textile"
    end

    it "Should return default extension" do
      OY::Markup.extension(nil).should == "textile"
      OY::Markup.extension(".textile").should == "textile"
      OY::Markup.extension("textile").should == "textile"            
    end
    
    it "Should have loaded some markup definitions" do
      OY::Markup.const_get(:Global).should == OY::Markup::Global
      OY::Markup.const_get(:Redcloth).should == OY::Markup::Redcloth
      OY::Markup.const_get(:Compare).should == OY::Markup::Compare    
    end

    it "Should select the right class for file extension (textile)" do
      OY::Markup.choose_for("textile") == OY::Markup::Redcloth
    end

    it "Should select the right class for file extension (compare)" do
      OY::Markup.choose_for("compare") == OY::Markup::Compare
    end

    it "Should select the right class for file extension (org)" do
      OY::Markup.choose_for("org").should == OY::Markup::Org
    end

    it "Should select the right class for file extension (overall)" do
      OY::Markup.choose_for("*") == OY::Markup::Global
    end

    it "Should list real_markups" do
      OY::Markup.real_markups.size.should > 0
    end
    
  end

  context "extensions"do
    
    it "Should list extensions" do
      OY::Markup.extensions.size.should > 1
    end

    it "Should return true on valid extension (textile)" do
      OY::Markup.valid_extension?("textile").should == true
      OY::Markup.valid_extension?(".textile").should == true      
    end
  end
end

describe OY::Markup::Global do
  it "Should replace wikilinks: [[Link]] => /link" do
    OY::Markup::Global.new("[[test]]").to_html.should eql("<a href='/test' class='oy-link o'>test</a>")
  end

  it "Should replace wikilinks: [[Link]] => /link (case sensitive)" do
    OY::Markup::Global.new("[[Test]]").to_html.should eql("<a href='/test' class='oy-link o'>Test</a>")
  end

  it "Should replace wikilinks: [[Link Title]] => /link with title" do
    OY::Markup::Global.new("[[test Title]]").to_html.should eql("<a href='/test' class='oy-link o'>Title</a>")
  end

  it "Should replace wikilinks: [[Link Title]] => /link with title (case sensitive)" do
    OY::Markup::Global.new("[[Test title]]").to_html.should eql("<a href='/test' class='oy-link o'>title</a>")
  end

  it "Should replace wikilinks: [[Link Title Foo]] => /link with title seperated with spaces" do
    OY::Markup::Global.new("[[Test Title Foo]]").to_html.should eql("<a href='/test' class='oy-link o'>Title Foo</a>")
  end

end

describe OY::Markup::Redcloth do
  it "Should apply RedCloth markup" do
    OY::Markup::Redcloth.new("h1. Hello World").to_html.should eql("<h1>Hello World</h1>")
  end
end


# describe OY::Markup::Compare do
#   it "Should apply Compare markup" do
#     wiki = repos(true).find_by_fragments("index")
#     v2, v1 = wiki.sha, wiki.history.first.sha
#     OY::Markup::Markups[:compare].new.to_html(wiki.diff(v2, v1).first.diff).first.sort_by{|a,b| a.to_s}.
#       should == [[:class, "gc"], [:ldln, "..."], [:line, "@@ -1 +1,3 @@"], [:rdln, "..."]]
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
