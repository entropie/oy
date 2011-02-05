#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module OY

  class Media < Wiki

    def self.media_path
      File.join(OY.path, "media")
    end

    def self.create_bare(path)
      npath = Repos.expand_path("media")
      FileUtils.mkdir_p(npath)
      Media.new(nil, nil, "media/#{path}")
    end

    def self.copy_uploaded_file(src, to)
      Dir.chdir(Media.media_path) do
        check = Repos.expand_path(to)
        FileUtils.mkdir_p(File.dirname(to))
        FileUtils.copy(src, to)
      end
    end

    def self.upload_file(name, extname, tempfile, filename, type)
      filec = File.open(tempfile.path, 'rb').read
      fname = "#{name}#{extname}"

      copy_uploaded_file(tempfile.path, fname)

      bmedia = OY::Media.create_bare(fname)
      media  = bmedia.create do |pg|
        pg.message = "update"
        pg.data = filec
      end
    end

    def is_media?
      true
    end

    def with_markup
      @blob.data
    end

    def media_identifier
      path.split("/")[1..-1].join("/")
    end

    def media_url(with_sha = false)
      add = with_sha ? "?sha=#{sha}" : ''
      frags = path.split("/")[1..-1]
      "/media/img/#{frags.join("/")}#{add}"
    end

    def permalink(with_sha = false)
      add = with_sha ? "?sha=#{sha}" : ''
      frags = path.split("/")[1..-1]
      "/oy/special/media/#{frags.join("/")}#{add}"
    end

    def history(rsha = nil)
      super(rsha, self.class)
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
