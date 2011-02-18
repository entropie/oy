#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module OY
  module WikiIndex

    def pages(only_pages = true)
      unless @pages
        rpath = Repos.expand_path(path)
        rpath = File.dirname(rpath) unless File.directory?(rpath)
        files = Dir.entries(rpath)
      end
      @pages ||= files.map{|f|
        next if f =~ /^\.+/
        frags = f.split("/")
        begin
          nfrags = File.join(path, *frags).split("/")
          repos.find_by_fragments(*nfrags)
        rescue NotFound
          repos.find_directory(*File.join(path, *frags)) unless only_pages
        end
      }.compact

      @pages
    end

    def self.indexpage_re
      /index#{OY::Markup.extension_regexp}/
    end

    def has_index?
      not pages.select{|page| page.path =~ WikiIndex.indexpage_re}.empty?
    end

    def index_page
      if has_index?
        pages.select{|page| page.path =~ WikiIndex.indexpage_re}.first
      else
        ws = OY::WikiSpecial.new(:index, path)
        ws.dir = self
        ws
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
