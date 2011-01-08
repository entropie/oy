#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module OY


  class NotFound < Exception
  end

  class AlreadyExist < Exception
  end

  class IllegalAccess < Exception
  end

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

    def ident
      ident = @path.split(".").first
    end
    
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
      else
        "/#{ident}"
      end
    end

    def diff(v1, v2)
      repos.git.diff(v1, v2, path)
    end

    # get complete history for +path+ Returns array of Wiki instances
    def history(rsha = nil, klass = Wiki)
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
            klass.new(blob, commit, b.path)
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

    # first applies Markup::Global then the corresponding Markup for the extension
    def with_markup(force_extension = nil)
      ret = @blob.data
      ["*", (force_extension || extension)].inject(ret){|memo, mup|
        Markup.choose_for(mup).new(memo).to_html
      }
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

      actor = options.actor || OY::Actor
      index.commit(options.message, parents, actor)
    end
    
    
    def update
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
      sha
    end

    def exist?
      @blob && @commit
    end
    
    def create
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
      with_markup
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
      ret = @commit.message
      if ret.strip.empty?
        return "&lt;no message&gt;"
      end
      ret
    end

    def title
      @blob.basename.split(".").first.capitalize
    end

    def size
      File.size(File.join(repos.path, path))
    end
    
  end


  class Media < Wiki

    MediaPath = File.join(OY.path, "media")
    FileUtils.mkdir_p(MediaPath) unless File.exist?(MediaPath)

    def with_markup
      @blob.data
    end

    def Media.create_bare(path)
      Media.new(nil, nil, "media/#{path}")
    end

    def self.upload_file(name, extname, tempfile, filename, type)
      filec = File.open(tempfile.path, 'rb').read
      fname = "#{name}#{extname}"
      
      Dir.chdir(Media::MediaPath) do
        check = Repos.expand_path(fname)
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

      Repos.expand_path(path)
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

    def media_identifier
      path.split("/")[1..-1].join("/")
    end
    
    def media_url(with_sha = false)
      add = with_sha ? "?sha=#{sha}" : ''
      frags = path.split("/")[1..-1]
      "/media/img/#{frags.join("/")}#{add}"
    end

    def permalink(with_sha = false)
      add = with_sha ? "?sha=#{sha}" : ''
      frags = path.split("/")[1..-1]
      "/oy/special/media/#{frags.join("/")}#{add}"
    end

    def history(rsha = nil)
      super(rsha, self.class)
    end
    
  end

  
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
