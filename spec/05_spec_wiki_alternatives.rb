#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "spec_helper"

describe "OY::Wiki::Alternatives" do

  context "find alternative for lala" do

    it "alternative should include :org" do
      Repos.alternatives("lala").keys.should include(:org)
    end

    it "alternatives size should be 1" do
      Repos.alternatives("lala").size.should == 1
    end

    it "alternative file name should be /tmp/testrepos/lala.org" do
      Repos.alternatives("lala").values.first.should == "/tmp/testrepos/lala.org"
    end

    it "should find the only choice if there is only one extension" do
      r = repos.find_by_fragments("lala")
      r.class.should == Wiki
      r.path.should == "lala.org"
    end
  end

  context "find alternative for double (2 choices)" do
    it "alternative should include :org" do
      Repos.alternatives("double").keys.should include(:org)
    end
    it "alternative should include :textile" do
      Repos.alternatives("double").keys.should include(:textile)
    end

    it "alternative should choose Markup.default_extension" do
      r = repos.find_by_fragments("double")
      r.class.should == Wiki
      r.path.should  == "double.textile"
    end

  end

  context "find alternative for doublewo (2 choices, without default)" do
    it "alternative should include :org" do
      Repos.alternatives("doublewo").keys.should include(:org)
    end
    it "alternative should include :textile" do
      Repos.alternatives("doublewo").keys.should include(:markdown)
    end

    it "alternative should raise AmbiguousChoice w/o default_extension" do
      expect{
        r = repos.find_by_fragments("doublewo")
      }.to raise_error(AmbiguousChoice)
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
