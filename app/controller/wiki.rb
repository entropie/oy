#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class WikiController < OYController
  map :/

  include OY

  def with_template(data)
    RedCloth.new(data).to_html
  end

  def index(*fragments)
    key, *arguments = fragments
    "#{key}:  #{arguments.join(",")}"

    methods = public_methods
    if public_methods.include?(key)
      call(key.to_sym, *arguments)
    else
      begin
        @wiki = repos.find_by_fragments(*fragments)
        if sha = request[:sha]
          @wiki = @wiki.history(sha)
        end
      rescue NotFound
        redirect WikiController.r(:create, *fragments)
      end
    end
  end
  
  def create(*fragments)
    @identifier = fragments.join("/")
  end

  def edit(*fragments)
    @wiki = repos.find_by_fragments(*fragments)
    @title = @wiki.path
    @action = :update
  end

  def update
    path = request[:path] or raise "no path given"

    redirect "/#{path}" unless request.post?
    
    wiki = repos.find_by_fragments(*path.split("/"))
    wiki.update do |pg|
      pg.message = request[:message] || ""
      pg.data    = request[:data]
    end

    redirect "/#{path}"
  end

  def new
    path = request[:path]
    path = path[1..-1]
    wiki = Wiki.create_bare("#{path}.textile")
    
    wiki.create do |pg|
      pg.message = request[:message]
      pg.data    = request[:data]
    end
    redirect "#{path}"
  end
  
  def create(*fragments)
    path = if fragments.empty? then request[:path] else "/#{fragments.join("/")}" end
    @action = :new
    @path = path
    @identifier = File.basename(@path)
  end

  def compare(*fragments)
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
