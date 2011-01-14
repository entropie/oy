#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module OY

  require "wiki/wikilock"
  
  class Wiki

    attr_reader :blob, :commit, :path, :repos

    attr_reader :date, :author, :sha

    attr_accessor :parent, :html_title

    include WikiLock
    
    def to_json
      to_hash.to_json
    end

    def to_hash
      {
        :title => html_title,
        :data  => raw_data,
        :sha   => sha,
        :url   => permalink
      }
    end
    
    # returns always false
    def is_media?
      false
    end
    
    def initialize(blob, commit, path)
      @blob, @commit, @path = blob, commit, path
    end

    # returns the prefix for the page which is basically the dirname of #path
    def vprefix
      r = File.dirname(path)
      r = if r == "." then "" else "#{r}/" end
      "/#{r}"
    end

    def repos
      @repos ||= OY.repos
    end

    def identifier
      @blob.basename.split(".").first.downcase
    end

    # permalink to page
    def permalink
      link(:perma)
    end

    def ident
      ident = @path.split(".").first
    end

    # Link to an action. What can be +nil+ for a standard page link
    # or one of the following symbols:
    #
    # * +perma+   permalink to page with sha
    # * +edit+    link to edit the page
    # * +version+ link to a specific history version
    # * +compare+ link to compare actual page to the first one in history
    # * +revert+  revert page to last version (page)
    # * +revert_do+ actually do the revert
    def link(what = nil)
      case what
      when :perma
        "/#{ident}?sha=#{sha}"
      when :edit 
        # FIXME:
        "/edit/#{ident}"
      when :version
        "/#{ident}?sha=#{history.first.sha}"
      when :history
        "/history/#{ident}"
      when :compare
        "/compare/#{sha}/#{history.first.sha}/#{ident}"
      when :revert
        "/revert/#{sha}/#{ident}"
      when :revert_do
        "/revert/#{sha}/#{ident}?do_it=1"
      else
        "/#{ident}"
      end
    end

    # get the diff for +v1+ +v2+
    def diff(v1, v2)
      repos.git.diff(v1, v2, path)
    end

    # revert page to specific sha or wiki page in history
    def revert_to(sha_or_wiki)
      wiki =
        if sha_or_wiki.kind_of?(String)
          wiki.history(sha)
        elsif sha_or_wiki.kind_of?(Wiki)
          sha_or_wiki
        else
          raise "missing input"
        end

      new_data = wiki.raw_data
      updated_wiki = update do |pg|
        pg.data    = new_data
        pg.message = "Revert from #{wiki.ref}"
      end
      updated_wiki
    end
    
    # get complete history for +path+ Returns array of Wiki instances
    def history(rsha = nil, klass = Wiki)
      access = GitAccess.new
      seen = false
      @history ||= repos.git.log("master", path).
        map{|commit|
        access.tree(commit.sha).select {|b|
          b.path == path
        }.map { |b|
          if commit.sha == self.commit.sha
            seen = true
            nil
          elsif seen
            blob = b.blob(repos.git)
            klass.new(blob, commit, b.path)
          end
        }.compact
      }.flatten

      if rsha
        return history.select{|his| his.sha == rsha}.first
      end

      access.refresh
      @history
    end

    # returns true if history is not empty
    def has_parent?
      not history.empty?
    end

    # returns parent version or nil if there is no one
    def parent
      has_parent? and history.first
    end

    # first applies Markup::Global then the corresponding Markup for the extension
    def with_markup(force_extension = nil)
      ret = @blob.data
      ["*", (force_extension || extension), "xml"].inject(ret){|memo, mup|
        Markup.choose_for(mup).new(memo, self).to_html
      }
    end

    # create a page
    def create(&block)
      update(&block)
    end

    # dummy for now
    def normalize_commit(commit)
      commit
    end
    
    def page_name(path)
      if segs = path.split("/")
        segs.first.downcase
      else
        path.downcase
      end.split(".").first
    end

    def page_filename(path = nil)
      path || self.path
    end
    
    # edits a page
    def update # :yields: option_struct
      raise FileLocked, "file is locked" if locked?
      
      opts = OpenStruct.new
      yield opts if block_given?

      Repos.expand_path(path)
      Repos.write(path){|fp| fp << opts.data}

      dir = ::File.dirname(path)
      dir = "" if dir == "."

      index = nil
      sha = commit_index(opts) do |idx|
        index = idx
        index.add(path, opts.data)
      end

      update_working_dir(index, dir, page_name(path))
      @history = nil
      self
    end

    def exist?
      @blob && @commit && true
    end
    
    # def create # :yields: option_hash
    #   opts = OpenStruct.new
    #   yield opts if block_given?

    #   Repos.expand_path(path)
    #   Repos.write(path){|fp| fp << opts.data}

    #   dir = ::File.dirname(path)
    #   dir = "" if dir == "."

    #   index = nil
    #   sha = commit_index(opts) do |idx|
    #     index = idx
    #     index.add(path, opts.data)
    #   end

    #   fragments = path.split("/").reject{|p| p.empty?}
    #   update_working_dir(index, '', page_name(path))
    #   @history = nil

    #   repos.find_by_fragments(*fragments)
    # end

    # creates an empty Wiki page
    def self.create_bare(path)
      ret = OY.repos.find_by_fragments(path)
    rescue NotFound
      wiki = Wiki.new(nil, nil, path)
    else
      raise AlreadyExist, "already in tree '#{path}'"
    end
    
    def sha
      @commit.sha
    end

    def ref
      @commit.sha[0..7]
    end

    def id
      @commit.id
    end
    
    def extension
      @blob.basename.split(".").last
    end
    
    def data
      @with_markup ||= with_markup
    end

    def parse_body
      data
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

    # returns commit message
    def message
      ret = @commit.message
      if ret.strip.empty?
        return "&lt;no message&gt;"
      end
      ret
    end

    def update_working_dir(index, dir, name, npath = nil)
      unless repos.git.bare
        tdir = File.join(repos.path)
        puts "Update: #{tdir}/ #{npath || path}"
        Dir.chdir(tdir) do
          repos.git.git.checkout({}, 'HEAD', '--', npath || path)
        end
      end
    end
    private :update_working_dir
    
    def commit_index(options = {}) # :yields: git_index
      normalize_commit(options)
      parents = [options.parent || repos.git.commit('master')]
      parents.flatten!
      parents.compact!
      index = OY.repos.git.index
      if tree = options.tree
        index.read_tree(tree)
      elsif parent = parents[0]
        index.read_tree(parent.tree.id)
      end
      yield index if block_given?

      actor = options.actor || OY::Actor
      index.commit(options.message, parents, actor)
    end
    private :commit_index
    
    # title of the page
    def title
      @blob.basename.split(".").first.capitalize
    end

    # Title of the page from first h1 in body. This is somewhat expensive to calculate
    # because the body is being parsed by the markup system.
    def html_title
      @html_title || title
    end

    def size
      File.size(File.join(repos.path, path))
    end
  end

  require "wiki/wikidir"
  require "wiki/media"
  require "wiki/physical"

end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
