#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module OY

  class Repos

    attr_reader    :path
    attr_reader    :git

    def self.alternatives?(*fragments)
      not alternatives(*fragments).empty?
    end

    def self.alternatives(*fragments)
      repos_path = Repos.expand_path(*fragments[0..-2])
      mup_exts = Markup.real_markups.map{|mu| ".#{mu.extension}"}

      mup_exts.map!{ |extension|
        frags = fragments.dup
        frags[-1] += extension
        [Markup.normalize_extension(extension).to_sym, File.join(repos_path, frags.last)]
      }.reject!{|ext, alt_file| not File.exist?(alt_file)}

      Hash[*mup_exts.flatten]
    end

    def self.expand_path(*npath)
      raise IllegalAccess, "illegal path" if npath.to_s.include?("..")
      File.join(OY.path, npath)
    end

    def self.exist?(path)
      File.exist?(expand_path(path))
    end

    def self.write(path)
      path = Repos.expand_path(path)
      FileUtils.mkdir_p(File.dirname(path))
      puts "Repos::write #{path}"
      File.open(path, 'w+') do |fp|
        yield fp
      end
    end

    def actor_from_string(str)
      author, emailprt = str.split("<")
      Grit::Actor.new(author, emailprt.delete(">"))
    end

    def initialize(path)
      @path = path
      @git = Grit::Repo.new(path)
    end

    def directory?(path)
      File.directory?(Repos.expand_path(path))
    end

    def directory(path)
      arg = path.split("/").reject{|a| a.empty?}
      arg = ["/"] if arg.empty?
      find_directory(*arg)
    end

    def find_by_path(path, kls = Media)
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

      # FIXME:
      klass = if path =~ /\.textile$/ then Wiki else kls end
      klass.new(file, commit, path)
    end

    def find_directory(*fragments)
      if rpath = Repos.expand_path(fragments.join("/")) and File.directory?(rpath)
        return WikiDir.new(fragments.join("/"))
      end
    end

    def find_by_fragments(*fragments)
      frags = sanitize_fragments(*fragments)

      commit = git.log("master", frags.join("/")).first
      raise NotFound, "not found '#{PP.pp(fragments, '')}'" unless commit

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
      fragments.reject!{|a| a.empty?}
      fragments[0] = "index" unless fragments[0]

      fragments.map!{|frag| URI.unescape(frag)}

      unless fragments[-1].split(".").size == 2

        alts = Repos.alternatives(*fragments)

        selected_ext = nil

        if alts.empty?
          # not found
        elsif alts.size == 1
          ext = alts.keys.first
          selected_ext = ext
        else
          defext = Markup.default_extension.to_sym

          # look for default markup
          if alts[defext]
            selected_ext = defext
          else
            raise AmbiguousChoice
          end
        end

        fragments[-1] = fragments[-1] += ".#{selected_ext}"
      end
      fragments
    end

  end

  class VirtualRepos < Repos
    attr_reader    :path
    attr_reader    :git

    def exist?
      true
    end

    def is_media?
      to_commit.is_media?
    end

    def extension
      path.split(".").last
    end

    def history(sha = nil)
      to_commit.history(sha)
    end

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
      @git ||= OY.repos(true).find_by_path(page.path)
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
