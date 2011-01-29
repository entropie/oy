#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module OY

  module Markup

    class << self
      attr_accessor :default_extension
    end

    # default extension without .
    self.default_extension = "textile"

    # Returns a Hash with all the markup abbrevs
    def self.markup_abbrevs
      @markup_abbrevs ||= {
        :textile  =>  "tt",
        :markdown =>  "md",
        :org      =>  "org"
      }
    end
    
    # returns extension string without leading .
    def self.normalize_extension(ext)
      ext = ext[1..-1] if ext[0] == ?.
      ext
    end
    
    # return default extension if +ext+ is nil or checks wheter +ext+ is valid
    def self.extension(ext)
      return default_extension unless ext
      if valid_extension?(ext)
        normalize_extension(ext)
      end
    end

    def self.real_markups
      @markups ||= Markups.to_a.select{|ext| not ext.is_virtual? }
    end
    
    def self.extensions
      @extensions ||= Markups.to_a.map{|mup| mup::extension }
    end

    def self.valid_extension?(ext)
      extensions.include?(normalize_extension(ext))
    end
    
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
      attr_reader :wiki
      
      class << self
        attr_accessor :extension
      end

      def self.is_virtual?
        false
      end
      
      def self.inherited(obj)
        Markups << obj
      end
      
      def initialize(data, wiki = nil)
        @wiki = wiki
        @data = data
      end

      def measure
        t = Time.now
        yield
        Time.now - t
      end

    end

    require "markup/global"
    require "markup/compare"
    require "markup/nokogiri"


    require "markup/redcloth"
    require "markup/org"
    require "markup/markdown"    
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
