#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module OY

  class Wiki

    attr_reader :blob, :commit, :path, :repos

    attr_reader :date, :author, :sha

    attr_accessor :parent, :html_title

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
    
    def is_media?
      false
    end
    
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
      when :revert
        "/revert/#{sha}/#{ident}"
      when :revert_do
        "/revert/#{sha}/#{ident}?do_it=1"
      else
        "/#{ident}"
      end
    end

    def diff(v1, v2)
      repos.git.diff(v1, v2, path)
    end

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

    def has_parent?
      not history.empty?
    end

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

    def page_filename(path = nil)
      path || self.path
    end
    
    def update_working_dir(index, dir, name)
      unless repos.git.bare
        tdir = ::File.join(repos.path)
        puts ">>> Update: #{tdir}/#{path}"
        Dir.chdir(tdir) do
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
      @history = nil
      self
    end

    def exist?
      @blob && @commit && true
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
      @history = nil
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

    def html_title
      @html_title || title
    end

    def size
      File.size(File.join(repos.path, path))
    end
    
  end


  class Media < Wiki

    MediaPath = File.join(OY.path, "media")
    FileUtils.mkdir_p(MediaPath) unless File.exist?(MediaPath)

    def is_media?
      true
    end
    
    def with_markup
      @blob.data
    end

    def Media.create_bare(path)
      npath = Repos.expand_path("media")
      FileUtils.mkdir_p(npath)
      Media.new(nil, nil, "media/#{path}")
    end

    def self.copy_uploaded_file(src, to)
      Dir.chdir(Media::MediaPath) do
        check = Repos.expand_path(to)
        FileUtils.mkdir_p(File.dirname(to))
        FileUtils.copy(src, to)
      end
    end
    
    def self.upload_file(name, extname, tempfile, filename, type)
      filec = File.open(tempfile.path, 'rb').read
      fname = "#{name}#{extname}"

      copy_uploaded_file(tempfile.path, fname)
      
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
      @history = nil
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

  class Physical < Wiki
    def title
      File.basename(path).split(".").first.capitalize
    end

    def data
      @data ||= File.open(Repos.expand_path(path), 'rb').read
      with_markup
    end

    def is_media?
      File.dirname(path) == "media"
    end
    
    def with_markup(force_extension = nil)
      ret = @data
      return ret if is_media?
      ["*", (force_extension || extension)].inject(ret){|memo, mup|
        Markup.choose_for(mup).new(memo).to_html
      }
    end

    def extension
      File.basename(path).split(".").last
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
