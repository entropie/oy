#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module OY

  module Markup

    if Gem.available?("org-ruby")
      require "org-ruby"

      class Org < Markup

        self.extension = "org"

        def to_html
          Orgmode::Parser.new(data).to_html
        end

      end
    else
      warn "Markup: org-ruby not available as template (`gem install org-ruby`)"
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
