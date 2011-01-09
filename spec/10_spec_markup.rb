#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "spec_helper"

describe OY::Markup do

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

  it "Should select the right class for file extension (overall)" do
    OY::Markup.choose_for("*") == OY::Markup::Global
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
end

describe OY::Markup::Redcloth do
  it "Should apply RedCloth markup" do
    OY::Markup::Redcloth.new("h1. Hello World").to_html.should eql("<h1>Hello World</h1>")
  end
end

describe OY::Markup::Compare do
  it "Should apply Compare markup" do
    wiki = repos(true).find_by_fragments("index")
    v2, v1 = wiki.sha, wiki.history.first.sha
    OY::Markup::Markups[:compare].new.to_html(wiki.diff(v2, v1).first.diff).first.
      should == {:line=>"@@ -1,3 +1 @@", :class=>"gc", :ldln=>"...", :rdln=>"..."}
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
