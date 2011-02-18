#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "spec_helper"

describe OY::WikiIndex do
  context "index page" do

    it "/ should have an index page" do
      WikiIndex.directories.each do |dir|
        p dir.index_page
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
