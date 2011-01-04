#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class WikiController < OYController
  map :/

  include OY
  
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
          unless @wiki.sha == sha
            parent = @wiki
            @wiki = @wiki.history(sha)
            @wiki.parent = parent
          end
        end
      rescue NotFound
        redirect WikiController.r(:create, *fragments)
      end
    end
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
    path = request[:path] or raise "no path given"
    path = path[1..-1] if path[0..0] == "/"
    wiki = Wiki.create_bare("#{path}.textile")

    wiki.create do |pg|
      pg.message = request[:message]
      pg.data    = request[:data]
    end
    redirect "#{path}"
  rescue AlreadyExist
    redirect request[:path]
  end
  
  def create(*fragments)
    path = if fragments.empty? then request[:path] else "/#{fragments.join("/")}" end
    redirect WikiController.r if path.to_s.empty?

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
