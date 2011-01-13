#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module OY

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
