#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#
module OY

  module Markup

    class Global < Markup

      class Processors < Array

        class << self
          attr_accessor :extern_processors
        end

        def self.register(o)
          (@extern_processors ||= []) << o
        end

        def with_extern
          @extern_processors ||= Processors.extern_processors.map do |eprocessor|
            eprocessor.new
          end
          @extern_processors + self
        end

        class Processor
        end
      end

      require "markup/processors/youtube"
      require "markup/processors/wikipedia"
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
