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
    pp @wiki
    @title = @wiki.path
    p request.params
    #exit
  end

  def update
    path = request[:path] or raise "no path given"
    p path
    repos.edit(@wiki, path)
    exit
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
