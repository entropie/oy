#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module OY

  module Markup

    # selects markup class by extension (w/o dot)
    def self.choose_for(extension)
      ret = Markups.to_a.select{|mu|
        mu::extension == extension
      }.first
    end
    
    class Markups
      
      @markups = []

      def self.[](obj)
        if obj.kind_of?(Symbol)
          @markups.select{|m| m.to_s.split("::").last.downcase.to_sym == obj}.first
        else
          @markups[obj]
        end

      end

      def self.<<(obj)
        @markups << obj
      end

      def self.to_a
        @markups
      end
    end

    class Markup

      include OY
      
      attr_reader :data

      class << self
        attr_accessor :extension
      end
      
      def self.inherited(obj)
        Markups << obj
      end
      
      def initialize(data)
        @data = data
      end
    end

    require "markup/global"
    require "markup/redcloth"    
    require "markup/compare"        
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
