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

  def mk_attributes(blob)
    {
      :name => blob.name
    }
  end

  
  def index(*fragments)
    key, *arguments = fragments
    "#{key}:  #{arguments.join(",")}"

    methods = public_methods
    if public_methods.include?(key)
      call(key.to_sym, *arguments)
    else
      @wiki = repos.find_by_fragments(*fragments)
    end
  end
  
  def create(*fragments)
  end

  def edit(*fragments)
    @wiki = repos.find_by_fragments(*fragments)
    @title = @wiki.path

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
