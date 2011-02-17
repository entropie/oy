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

  class Preview < Physical

    attr_accessor :data

    attr_accessor :path

    attr_accessor :extension

    def initialize
    end

    def is_media?
      false
    end

    def self.create
      wiki = self.new
      yield wiki
      wiki
    end

    def with_markup(fextension = "textile")
      super(extension)
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
