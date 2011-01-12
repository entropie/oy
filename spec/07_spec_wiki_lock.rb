#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "spec_helper"


describe OY::Wiki, "lock" do

  context "lock a file" do

    it "should respond_to #lockfile_path" do
      r("index").lockfile_path.should == "index.textile.locked"
    end

    it "should respond_to #lockdir_path" do
      r("index").lockdir_path.should == "./.locked"
    end
    
    it "should exist" do
      r("index").should exist
    end

    it "should not be locked" do
      r("index").should_not be_locked
    end

    it "should be lockeable" do
      r("index").lock!.should == true
    end

    it "should be locked" do
      r("index").should be_locked
    end

  end

  context "try to modify a locked file" do
    it "should raise an error" do
      expect{
        r("index").update do |pg|
          pg.message = "nobody will see"
          pg.data    = "nobody will see"
        end
      }.to raise_error(OY::FileLocked)
    end
  end

  context "unlock a file" do

    it "should be unlockeable" do
      r("index").unlock!.should == true
    end

    it "should be possible to update page now" do
      expect{
        r("index").update do |pg|
          pg.message = "everybody will see"
          pg.data    = "everybody will see"
        end
      }.to_not raise_error(OY::FileLocked)
    end
    
  end

  context "lock a directory" do

    it "should be lockeable" do
      r("index").lock_directory!.should == true
    end

    it "should be locked" do
      r("index").should be_locked
    end

  end

  context "unlock a directory" do
    it "should be unlockeable" do
      r("index").unlock_directory!.should == true
    end

    it "should not be locked" do
      r("index").should_not be_locked
    end

  end

  context "lock a file in a subdir" do

    it "should be possible to lock a file" do
      r("bar", "test").lock!.should == true
    end

    it "should be locked now" do
      r("bar", "test").locked?.should == true
    end

    it "should raise an error if we try to update locked file" do
      expect{
        r("bar", "test").update do |pg|
          pg.message = "nobody will see"
          pg.data    = "nobody will see"
        end
      }.to raise_error(OY::FileLocked)
    end

    it "should be unlockable" do
      r("bar", "test").unlock!.should == true
    end

    it "should not be locked" do
      r("bar", "test").locked?.should == false
    end

  end


  context "lock a subdir" do

    it "should be possible to lock a directory" do
      p r("bar")
      r("bar").lock!.should == true
    end

    it "should be locked now" do
      r("bar").locked?.should == true
    end

    it "should raise an error if we try to update locked file" do
      expect{
        r("bar", "test").update do |pg|
          pg.message = "nobody will see"
          pg.data    = "nobody will see"
        end
      }.to raise_error(OY::FileLocked)
    end

    it "files should NOT be unlockable" do
      expect{
        r("bar", "test").unlock!
      }.to raise_error(OY::FileNotLocked)
    end

    it "dir should be unlockable" do
      r("bar").unlock!.should == true
    end

    it "dir should be not locked anymore" do
      r("bar").locked?.should == false
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
