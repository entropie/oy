#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module OY

  class Repos

    attr_reader    :path
    attr_reader    :git

    def self.expand_path(npath)
      raise IllegalAccess, "illegal path" if npath.to_s.include?("..")
      File.join(OY.path, npath)
    end

    def self.write(path)
      path = Repos.expand_path(path)
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'w+') do |fp|
        yield fp
      end
    end
    
    def initialize(path)
      @path = path
      @git = Grit::Repo.new(path)
    end

    def find_by_path(path)
      file = nil

      commit = git.log("master", path).first

      raise NotFound, "not found" unless commit
      tree = commit.tree("master")
      
      path.split("/").each do |frag|
        sub = tree/frag
        case sub
        when Grit::Tree
          tree = sub
        when Grit::Blob
          file = tree/frag
        else
          raise NotFound, "not found"
        end
      end

      klass = if path =~ /\.textile$/ then Wiki else Media end
      klass.new(file, commit, path)
    end
    
    def find_by_fragments(*fragments)
      frags = sanitize_fragments(*fragments)

      commit = git.log("master", frags.join("/")).first
      
      raise NotFound, "not found" unless commit

      tree = commit.tree("master")
      file = nil
      frags.each do |frag|
        sub = tree/frag
        case sub
        when Grit::Tree
          tree = sub
        when Grit::Blob
          file = tree/frag
        else
          raise NotFound, "not found"
        end
      end
      Wiki.new(file, commit, frags.join("/"))
    end

    def sanitize_fragments(*fragments)
      fragments[0] = "index" unless fragments[0]

      unless fragments[-1].split(".").size == 2
        fragments[-1] = fragments[-1] += ".textile" unless fragments[-1] =~ /\.textile$/
      end
      fragments
    end
    
  end

  class VirtualRepos < Repos
    attr_reader    :path
    attr_reader    :git
    
    def commit
      to_commit.commit
    end

    def permalink
      to_commit.permalink
    end

    def date
      to_commit.date
    end

    def author
      to_commit.author
    end

    def has_parent?
      to_commit.has_parent?
    end

    def link(*args)
      to_commit.link(*args)
    end
    
    def initialize(path)
      @path = path
    end

    def title
      @page.title
    end

    def data
      @page.data
    end
    
    def page
      @page
    end
    
    def to_commit
      @git ||= OY.repos(true).find_by_fragments(*page.path.split("/"))
    end

    def find_by_path(path)
      Repos.expand_path(path)
      Dir.chdir(File.join(OY.repos.path)) do
        @page = Physical.new(nil, nil, path)
      end
      self
    end
    
    def find_by_fragments(*fragments)
      frags = sanitize_fragments(*fragments)
      Dir.chdir(path) do
        @page = Physical.new(nil, nil, frags.join("/"))
      end
      self
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
