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
      pages.size.should == 2

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


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
