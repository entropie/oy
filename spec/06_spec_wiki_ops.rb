#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "spec_helper"


describe OY::Wiki, "operations" do

  context "Create a page" do

    it "Should not exist" do
      expect{ r }.to raise_error(OY::NotFound)
    end

    it "Should be possible to create" do
      page = Wiki.create_bare('test/spec.textile')
      page.should_not exist
      npage = page.create do |pg|
        pg.message = "Message from Spec"
        pg.data    = "Data from Spec"
      end
    end

     it "Should exist" do
      repos.find_by_fragments('test', 'spec.textile').should exist
     end
    
    it "Should have a message" do
      repos.find_by_fragments('test', 'spec.textile').message.should == "Message from Spec"
    end

     it "Should have #raw_data" do
      repos.find_by_fragments('test', 'spec.textile').raw_data.should == "Data from Spec"
     end

    it "Should have #data with markup" do
      repos.find_by_fragments('test', 'spec.textile').data.should == "<p>Data from Spec</p>"
     end

    it "Should not have a history" do
      repos.find_by_fragments('test', 'spec.textile').parent.should == false
      repos.find_by_fragments('test', 'spec.textile').history.should == []
    end

  end

  context "Edit a page" do
    
    it "Should be possible to edit" do
      wiki = repos.find_by_fragments('test', 'spec.textile')
      wiki.update do |pg|
        pg.message = "New message from Spec"
        pg.data    = "New data from Spec"        
      end
    end

    it "Should habe a parent" do
      wiki = repos.find_by_fragments('test', 'spec.textile')
      wiki.has_parent?.should == true
    end

    it "Should habe a history" do
      wiki = repos.find_by_fragments('test', 'spec.textile')
      wiki.history.size.should == 1
    end

    it "Should have a new message" do
      repos.find_by_fragments('test', 'spec.textile').message.should == "New message from Spec"
    end

     it "Should have new #raw_data" do
      repos.find_by_fragments('test', 'spec.textile').raw_data.should == "New data from Spec"
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
