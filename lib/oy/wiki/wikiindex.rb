#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "find"

module OY
  module WikiIndex

    ExcludeList = [".git", "_public", "_view", "media"]

    # returns ANY directories in the repos except internal ones
    # Array consists of WikiDir instances.
    def self.directories(force = false)
      if not @index_pages or force
        path = OY.path
        dirs = ["/"]
        Find.find(path) do |file|
          nfile = file.gsub(/#{path}/, '')
          next if nfile.empty?
          Find.prune if ExcludeList.include?(nfile.split("/").first)
          dirs << nfile if File.directory?(file)
        end
        @index_pages = dirs.map{|dir|
          ndir = dir.split("/")
          ndir = ["/"] if ndir.empty?
          OY.repos.find_directory(*ndir)
        }
      end
      @index_pages
    end

    def pages(only_pages = true)
      unless @pages
        rpath = Repos.expand_path(path)
        rpath = File.dirname(rpath) unless File.directory?(rpath)
        files = Dir.entries(rpath)

        @pages = files.map{|f|
          next if f =~ /^\.+/
          frags = f.split("/")
          begin
            nfrags = File.join(path, *frags).split("/")
            repos.find_by_fragments(*nfrags)
          rescue NotFound
            repos.find_directory(*File.join(path, *frags)) unless only_pages
          end
        }.compact
      end
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
