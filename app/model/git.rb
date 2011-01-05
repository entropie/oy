#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class NotFound < Exception
end

class AlreadyExist < Exception
end

module OY

  class Wiki

    attr_reader :blob, :commit, :path, :repos

    attr_reader :date, :author, :sha

    attr_accessor :parent
    
    def initialize(blob, commit, path)
      @blob, @commit, @path = blob, commit, path
    end

    def vprefix
      r = File.dirname(path)
      r = if r == "." then "" else "#{r}/" end
      "/#{r}"
    end
    
    def repos
      OY.repos
    end

    def identifier
      @blob.basename.split(".").first.downcase
    end

    def permalink
      link(:perma)
    end
    
    def link(what = nil)
      ident = @path.split(".").first
      case what
      when :perma
        "#{ident}?sha=#{sha}"
      when :edit 
        # FIXME:
        "/edit/#{ident}"
      when :version
        "/#{ident}?sha=#{history.first.sha}"
      else
        "#{ident}"
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


    def parse_result(result)
      r = result.gsub(/\[{2}([a-zA-Z0-9\/]*?)( [a-zA-Z0-9\/]*?)?\]{2}/){|match|
        url = $1.downcase
        cls = begin
                repos.find_by_fragments(url) and "x"
              rescue NotFound
                "o"
              end
        "<a href='/#{url}' class='oy-link #{cls}'>#{($2 || $1).strip}</a>"
      }
      r
    end

    
    def with_template(data)
      result = parse_result(data)
      case extension
      when "textile"
        RedCloth.new(result).to_html
      else
        data
      end
    end

    def create(&block)
      update(&block)
    end

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

    def page_filename(path)
      path
    end
    
    def update_working_dir(index, dir, name)
      unless repos.git.bare
        puts ">>> #{:uwd}: #{dir}"
        Dir.chdir(::File.join(repos.path, '..')) do
          repos.git.git.checkout({}, 'HEAD', '--', path)
        end
      end
    end
    
    
    def commit_index(options = {})
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

      
      actor = options.actor || Grit::Actor.new("michael", "foo@bar.baz")
      index.commit(options.message, parents, actor)
    end
    
    
    def update
      opts = OpenStruct.new
      yield opts if block_given?

      dir = ::File.dirname(path)
      dir = "" if dir == "."

      index = nil
      sha = commit_index(opts) do |idx|
        index = idx
        index.add(path, opts.data)
      end
      
      Repos.write(path){|fp| fp << opts.data}

      update_working_dir(index, dir, page_name(path))
      sha
    end

    def exist?
      @blob && @commit
    end
    
    def create
      opts = OpenStruct.new
      yield opts if block_given?

      Repos.write(path){|fp| fp << opts.data}

      dir = ::File.dirname(path)
      dir = "" if dir == "."

      index = nil
      sha = commit_index(opts) do |idx|
        index = idx
        index.add(path, opts.data)
      end
      fragments = path.split("/").reject{|p| p.empty?}
      update_working_dir(index, '', page_name(path))
      repos.find_by_fragments(*fragments)
    end

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


  class Media < Wiki

    MediaPath = File.join(OY.path, "media")
    FileUtils.mkdir_p(MediaPath)

    def Media.create_bare(path)
      Media.new(nil, nil, "media/#{path}")
    end

    def self.upload_file(name, extname, tempfile, filename, type)
      filec = File.open(tempfile.path, 'rb').read
      fname = "#{name}#{extname}"
      
      Dir.chdir(Media::MediaPath) do
        FileUtils.mkdir_p(File.dirname(fname))
        FileUtils.copy(tempfile.path, fname)
      end
      bmedia = OY::Media.create_bare(fname)
      media  = bmedia.create do |pg|
        pg.message = "update"
        pg.data = filec
      end
    end
    
    def create
      opts = OpenStruct.new
      yield opts if block_given?

      Repos.write(path){|fp| fp << opts.data}

      dir = ::File.dirname(path)
      dir = "" if dir == "."

      index = nil
      sha = commit_index(opts) do |idx|
        index = idx
        index.add(path, opts.data)
      end
      fragments = path.split("/").reject{|p| p.empty?}
      update_working_dir(index, '', page_name(path))
    end

  end

  
  class Repos

    attr_reader    :path
    attr_reader    :git

    def self.expand_path(npath)
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

    def find_by_fragments(*fragments)
      access = GitAccess.new
      file = nil
      # FIXME:
      fragments[0] = "index" unless fragments[0]
      fragments[-1] = fragments[-1] += ".textile" unless fragments[-1] =~ /\.textile$/

      commit = git.log("master", fragments.join("/")).first

      raise NotFound, "not found" unless commit
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
