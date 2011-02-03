#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class WikiController < OYController
  map :/

  helper :cache
  
  def img(*fragments)
    redirect MediaController.r(:img, *fragments)
  end

  def clear_cache(*fragments)
    fragments = 'index' if fragments.empty?
    cache_key = Wiki.mk_cache_key_from_fragments(*fragments)
    cache.delete(cache_key)
    redirect_referer
  end

  def index(*fragments)
    add_repos_paths # FIXME: do this at startup
    
    key, *arguments = fragments

    @sha = request[:sha]
    
    if public_methods.include?(key)
      call(key.to_sym, *arguments)
    else
      # FIXME: maybe cache historical pages too
      @wiki, @time, @cached = find_by_fragments(*fragments)

      if @sha and @wiki.sha != @sha
        parent = @wiki
        @wiki = @wiki.history(@sha)
        @wiki.parent = parent
      end
      @title = @wiki.html_title
    end
  rescue NotFound
    redirect WikiController.r(:create, *fragments)
  end

  def history(*fragments)
    @wiki = repos.find_by_fragments(*fragments)
    @wikis = @wiki.history
  end
  
  def edit(*fragments)
    @wiki = repos.find_by_fragments(*fragments)
    flash[:error] = "Page is locked."
    redirect @wiki.link if @wiki.locked?
    @extension = @wiki.extension
    @title = @wiki.path
    @action = :update
  end

  def preview
    raise NotAllowed unless request.post?
    
    path = request[:path] or raise "no path given"
    extension = request[:extension] || "textile"

    @preview_wiki = Preview.create{|w|
      w.data = request[:data].to_s.strip
      w.path = request[:path]
      w.extension = extension
    }
  end
  
  def update
    path = request[:path] or raise "no path given"
    redirect WikiController.r(path) unless request.post?

    wiki = repos.find_by_fragments(*path.split("/"))
    wiki.update do |pg|
      pg.message = request[:message] || ""
      pg.data    = request[:data]
    end
    cache.delete(wiki.cache_key)
    redirect wiki.link
  end

  def new
    raise NotAllowed unless request.post?
    
    path = request[:path] or raise "no path given"

    path = Wiki.normalize_path(path)

    extension = Markup.extension(request[:markup])
    wiki = Wiki.create_bare("#{path}.#{extension}")

    wiki.create do |pg|
      pg.message = request[:message]
      pg.data    = request[:data]
    end

    redirect wiki.link
  rescue AlreadyExist
    redirect WikiController.r(request[:path])
  end
  
  def create(*fragments)
    path = if fragments.empty? then request[:path] else "/#{fragments.join("/")}" end
    redirect WikiController.r if path.to_s.empty?

    # check if page exists
    begin
      wiki = repos.find_by_fragments(*path.split("/"))
    rescue NotFound
    else
      redirect wiki.path
    end
    
    @action = :new
    @path = path
    @identifier = File.basename(@path)
  end

  def compare(v1, v2, *fragments)
    begin
      wiki = repos.find_by_fragments(*fragments)
    rescue NotFound
    else
      @data = OY::Markup::Markups[:compare].new.to_html(wiki.diff(v2, v1).first.diff)
    end
  end

  def revert(sha, *fragments)
    @wiki = repos.find_by_fragments(*fragments)
    @wiki.parse_body
    @hist_page = @wiki.history(sha)

    if request[:do_it] == "1"
      raise NotAllowed unless request.post?
      redirect @wiki.revert_to(@hist_page).link
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
