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
  context "Wikilinks" do


    context "Don't Exist w/o Title" do
      it "Should replace wikilinks: [[Test]];  /test => test" do
        OY::Markup::Global.new("[[Test]]").to_html.should eql("<a href='/test' class='oy-link o'>Test</a>")
      end

      it "Should replace wikilinks: [[/Test]]; /test => test" do
        OY::Markup::Global.new("[[/Test]]").to_html.should eql("<a href='/test' class='oy-link o'>Test</a>")
      end

      it "Should replace wikilinks: [[Test/foo/bar]]; /test/foo/bar => test/foo/bar" do
        OY::Markup::Global.new("[[Test/foo/bar]]").to_html.should eql("<a href='/test/foo/bar' class='oy-link o'>Test/foo/bar</a>")
      end
    end

    context "Existing w/o Title" do
      it "Should replace wikilinks: [[Foo]];  /foo => foo" do
        OY::Markup::Global.new("[[Foo]]").to_html.should eql("<a href='/foo' class='oy-link x'>Foo</a>")
      end

      it "Should replace wikilinks: [[/Foo]]; /foo => foo" do
        OY::Markup::Global.new("[[/Foo]]").to_html.should eql("<a href='/foo' class='oy-link x'>Foo</a>")
      end

      it "Should replace wikilinks: [[Test/foo]]; /test/foo => test/foo" do
        OY::Markup::Global.new("[[Test/foo]]").to_html.should eql("<a href='/test/foo' class='oy-link x'>Test/foo</a>")
      end
    end

    context "Links with Title" do

      it "Should replace wikilinks: [[test Title]]; => /test with Title" do
        OY::Markup::Global.new("[[test Title]]").to_html.should eql("<a href='/test' class='oy-link o'>Title</a>")
      end

      it "Should replace wikilinks: [[test Long Title is long]]; => /test with Long Title is long" do
        OY::Markup::Global.new("[[test Long Title is long]]").to_html.
          should eql("<a href='/test' class='oy-link o'>Long Title is long</a>")
      end

      it "Should replace wikilinks: [[test Äöü]]; => /test with Unicode Title" do
        OY::Markup::Global.new("[[test Äöü]]").to_html.should eql("<a href='/test' class='oy-link o'>Äöü</a>")
      end

      it "Should replace wikilinks: [[Äöü]]; => /äöü" do
        OY::Markup::Global.new("[[Äöü]]").to_html.should eql("<a href='/äöü' class='oy-link o'>Äöü</a>")
      end

      it "Should replace wikilinks: [[test Äöü]]; => /test with Unicode Title" do
        OY::Markup::Global.new("[[test Äöü]]").to_html.should eql("<a href='/test' class='oy-link o'>Äöü</a>")
      end

    end

    context "Alternatives" do

      it "should be possible to link direct to a page with extension (double) w/o title" do
        OY::Markup::Global.new("[[Double.org]]").to_html.
          should eql("<a href='/double.org' class='oy-link o'>Double.org</a>")
      end

      it "should be possible to link direct to a page with extension (double) with title" do
        OY::Markup::Global.new("[[Double.org Title]]").to_html.
          should eql("<a href='/double.org' class='oy-link o'>Title</a>")
      end
      
      it "should add alternatives after base link (/double)" do
        base_link = "<a href='/double.textile' class='oy-link x'>Double</a>"
        add_link  = "<a href='/double.org' class='oy-link alt'><sup>1</sup></a>"
        OY::Markup::Global.new("[[Double]]").to_html.
          should eql(base_link + add_link)
      end

      it "should add alternatives without base link (/doublewo)" do
        base_link = "<a href='/doublewo.markdown' class='oy-link x'>Doublewo</a>"
        add_link  = "<a href='/doublewo.org' class='oy-link alt'><sup>1</sup></a>"
        OY::Markup::Global.new("[[Doublewo]]").to_html.
          should eql(base_link + add_link)
      end
      
    end
    
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
