#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class NotFound < Exception
end

module OY

  class Wiki

    attr_reader :blob, :commit, :path
    
    def initialize(blob, commit, path)
      @blob, @commit, @path = blob, commit, path
    end

    def identifier
      @blob.basename.split(".").first.capitalize
    end
    
    def link(what = nil)
      case what
      when :edit
        # FIXME:
        "/edit/#{@path.split(".").first}"
      else
        "/#{@path.split(".").first}"
      end
    end
    
    def with_template(data)
      case extension
      when "textile"
        RedCloth.new(data).to_html
      else
        data
      end
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
      @commit.author.to_s
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
      file = nil
      commit = @git.commits.first
      pp fragments
      # FIXME:
      fragments[0] = "index" unless fragments[0]
      fragments[-1] = fragments[-1] += ".textile"
      
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

    # def method_missing(m, *a, &b)
    #   if repos.respond_to?(m)
    #     repos.send(m, *a, &b)
    #   else
    #     super
    #   end
    # end
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
