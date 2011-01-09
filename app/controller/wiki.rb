#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class WikiController < OYController
  map :/

  include OY

  def img(fragments)
    redirect MediaController.r(:img, *fragments)
  end
  
  def index(*fragments)
    key, *arguments = fragments

    methods = public_methods

    if methods.include?(key)
      call(key.to_sym, *arguments)
    else
      @wiki = repos.find_by_fragments(*fragments)

      if sha = request[:sha]
        unless @wiki.sha == sha
          parent = @wiki
          @wiki = @wiki.history(sha)
          @wiki.parent = parent
        end
      end
      @wiki.parse_body
      @title = @wiki.title

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
    @title = @wiki.path
    @action = :update
  end

  def update
    path = request[:path] or raise "no path given"

    redirect WikiController.r(path) unless request.post?
    
    wiki = repos.find_by_fragments(*path.split("/"))
    wiki.update do |pg|
      pg.message = request[:message] || ""
      pg.data    = request[:data]
    end
    redirect WikiController.r(path)
  end

  def new
    path = request[:path] or raise "no path given"
    path = path[1..-1] if path[0..0] == "/"
    wiki = Wiki.create_bare("#{path}.textile")

    wiki.create do |pg|
      pg.message = request[:message]
      pg.data    = request[:data]
    end

    redirect WikiController.r(path)
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
      redirect WikiController.r(wiki.path)
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


end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
