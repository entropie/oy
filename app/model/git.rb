#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class NotFound < Exception
end

module OY

  class Wiki

    attr_reader :blob, :commit, :path, :repos

    attr_reader :date, :author, :sha
    
    def initialize(blob, commit, path)
      @blob, @commit, @path = blob, commit, path
    end

    def repos
      OY.repos
    end

    def identifier
      @blob.basename.split(".").first.capitalize
    end
    
    def link(what = nil)
      ident = @path.split(".").first
      case what
      when :edit 
        # FIXME:
        "/edit/#{ident}"
      when :version
        "/#{ident}?sha=#{history.first.sha}"
      else
        ""
      end
    end

    # get complete history for +path+ Returns array of Wiki instances
    def history(rsha = nil)
      access = GitAccess.new
      seen = false
      @history = repos.git.log("master", path).
        map{|commit|
        access.tree(commit.sha).select {|b|
          b.path == path
        }.map { |b|
          if commit.sha == self.commit.sha
            seen = true
            nil
          elsif seen
            blob = b.blob(repos.git)
            Wiki.new(blob, commit, b.path)
          end
        }.compact
      }.flatten

      if rsha
        return history.select{|his| his.sha == rsha}.first
      end

      @history
    end

    def has_parent?
      not history.empty?
    end

    def parent
      has_parent? and history.first
    end
    
    def with_template(data)
      case extension
      when "textile"
        RedCloth.new(data).to_html
      else
        data
      end
    end

    def update
      
    end
    
    def sha
      @commit.sha
    end

    def id
      @commit.id
    end
    
    def extension
      @blob.basename.split(".").last
    end
    
    def data
      with_template(@blob.data)
    end

    def raw_data
      @blob.data
    end

    def author
      @commit.author.name
    end

    def date
      @commit.committed_date
    end

    def message
      @commit.message
    end

    def title
      @blob.basename.split(".").first.capitalize
    end
    
  end
  
  class Repos

    attr_reader    :path
    attr_reader    :git
    
    def initialize(path)
      @path = path
      @git = Grit::Repo.new(path)
    end
    
    def find_by_fragments(*fragments)
      access = GitAccess.new
      file = nil
      # FIXME:
      fragments[0] = "index" unless fragments[0]
      fragments[-1] = fragments[-1] += ".textile"

      commit = git.log("master", fragments.join("/")).first
      
      tree = commit.tree("master")
      
      fragments.each do |frag|
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
      Wiki.new(file, commit, fragments.join("/"))
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
