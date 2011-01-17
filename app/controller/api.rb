#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#



class ApiController < OYController

  map "/api"
  layout :none

  include OY

  
  def GET(*fragments)
    response[ 'Content-Type' ] = 'application/json'
    page = repos.find_by_fragments(*fragments)
    respond_ok(page.to_hash)
  end

  def POST(*fragments)
    response[ 'Content-Type' ] = 'application/json'

    data, author, msg = request[:data], request[:author], request[:message]

    ext = Markup.extension(request[:markup])
    
    author = repos.actor_from_string(author)
    fragments.last << ".#{ext}"

    initial = false
    
    begin
      page = repos.find_by_fragments(*fragments)
    rescue NotFound
      initial = true
      page = Wiki.create_bare(fragments.join("/"))
    end

    page = page.update do |pg|
      pg.actor   = author
      pg.data    = data
      pg.message = msg
    end
    respond_ok(:size => page.size, :url => page.link, :initial => initial)
  end

  private

  def respond_ok(o = {})
    o.merge(:ok => true).to_json
  end
  
  def respond_fail(o = {})
    o.merge(:ok => false).to_json
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
