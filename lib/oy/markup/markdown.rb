#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module OY

  module Markup

    if Gem.available?("rdiscount")
      require "rdiscount"

      class Markdown < Markup

        self.extension = "markdown"

        def to_html
          RDiscount.new(data).to_html
        end

      end
    else
      warn "Markup: markdown not available as template (`gem install rdiscount`)"
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
