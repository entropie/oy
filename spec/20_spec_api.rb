#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "spec_helper"

describe Api do
  before(:each) do
    @api = api
  end

  it "should have a @host" do
    @api.host.should == "http://localhost:8200/"
  end

  it "should returnt he right url" do
    @api.url_path("foo/bar/baz").should == "/api/GET/foo/bar/baz"
    @api.url_path("foo/baz", "post").should == "/api/POST/foo/baz"
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
