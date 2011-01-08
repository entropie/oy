#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "helper"

describe OY do

  it "Should have a Source path" do
    OY::Source.should eq(File.dirname(File.dirname(File.expand_path(__FILE__))))
  end

  it "Should be possible to change the Repos.path" do
    OY.path = File.join(OY::Source, "spec/testrepos")
    OY.path.should == File.join(OY::Source, "spec/testrepos")
  end
  
  it "Should habe a default Actor" do
    OY::Actor.class.should == Grit::Actor
  end

  it "Should have a Repos" do
    OY.repos.class.should == Repos
  end

  it "Should have a Virtual Repos" do
    OY.repos(false).class.should == VirtualRepos
  end

  it "Should require LIBs" do
    OY.const_get(:Markup).should == Markup
    OY.const_get(:Repos).should == Repos
    OY.const_get(:GitAccess).should == GitAccess    
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
