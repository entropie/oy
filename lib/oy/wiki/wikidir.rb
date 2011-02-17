#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module OY

  class WikiDir < Wiki

    include WikiLock

    def self.indexpage_re
      /index#{OY::Markup.extension_regexp}/
    end

    def has_index?
      not pages.select{|page| page.path =~ WikiDir.indexpage_re}.empty?
    end

    def index_page
      if has_index?
        pages.select{|page| page.path =~ WikiDir.indexpage_re}.first
      else
        ws = OY::WikiSpecial.new(:index, path)
        ws.dir = self
        ws
      end
    end

    def lockdir_path
      check = Repos.expand_path(path)
      File.join(path, ".locked")
    end

    def lock!
      lock_directory!
      # FIXME: ???
      Dir.chdir(repos.path){ repos.git.git.checkout({}, 'HEAD', '--', lockdir_path) }
      true
    end

    def unlock!
      update_repos_lockfiles(:delete, lockdir_path)
      # FIXME:
      Dir.chdir(repos.path){ repos.git.git.rm({:f => true}, 'HEAD', '--', lockdir_path) }
      true
    end

    def identifier
      path
    end

    # FIXME:
    def [](obj)
      page_path = path + "/#{obj.to_s}"
      repos.find_by_fragments(*page_path.split("/"))
    end

    def pages(only_pages = true)
      unless @pages
        rpath = Repos.expand_path(path)
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

    def exist?
      File.directory?(Repos.expand_path(path))
    end

    def initialize(dir)
      @path = dir
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
