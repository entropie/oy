#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "spec_helper"

describe OY::WikiDir do

  context "Base" do

    it "should exist" do
      repos.find_directory("/").should exist
    end

    it "should have pages" do
      pages = repos.find_directory("/").pages
      pages.size.should == 7

      pages.all?{|wiki| wiki.kind_of?(Wiki) }.should == true
    end

    it "should respond to #lock!" do
      repos.find_directory("/").should respond_to("lock!")
    end

    it "should respond to #unlock!" do
      repos.find_directory("/").should respond_to("unlock!")
    end

    it "should respond to #locked?" do
      repos.find_directory("/").should respond_to("locked?")
    end

    it "should not be locked" do
      repos.find_directory("/").locked?.should == false
    end
  end

end

describe OY::Wiki do
  context "index page" do

    it "/ should have an index page" do
      repos.find_directory("/").has_index?.should == true
    end

    it "/bar should have no index page" do
      repos.directory("/bar").has_index?.should == false
    end

    it "/ should return an index page" do
      repos.directory("/").index_page.kind_of?(Wiki).should == true
    end
  end

  describe OY::WikiSpecial do
    context "index page" do

      # it "/ should have an index page" do
      #   WikiSpecial.new(:index, "index.textile").title.should == "Index"
      #   WikiSpecial.new(:index, "index.textile").data.should_not == nil
      # end

      it "should raise NotFound" do
        expect{
          WikiSpecial.new(:lala, "/index.textile")
        }.to raise_error(OY::NotFound)
      end

      it "/ should have an index page" do
        puts
        puts repos.directory("/")
        puts repos.directory("/bar").index_page.data
        puts
      end

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
