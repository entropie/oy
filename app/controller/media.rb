#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class MediaController < OYController
  map "/media"

  engine :None
  include OY

  set_layout_except 'layout' => [:img]

  def img(*fragments)
    if request[:p]
      redirect SpecialController.r(:media, *fragments)
    else
      file_path = File.join(OY::Media.media_path, *fragments)

      raise NotFound, "not found" unless File.exist?(file_path)

      content_type ||= Rack::Mime.mime_type(::File.extname(file_path))
      response['Content-Length'] = ::File.size(file_path).to_s
      response["Content-Type"] = "image/jpeg"

      @img = repos(false).find_by_path("media/#{fragments.join("/")}")
      if sha = request[:sha]
        @img = repos.find_by_path("media/#{fragments.join("/")}")
        @img = @img.history(sha)
      end
      @img.data
    end
  rescue NotFound
    ''
  end

  def upload
    if request.post?
      name = request[:name]
      tempfile, filename, @type = request[:file].
        values_at(:tempfile, :filename, :type)

      @extname, @basename = File.extname(filename), File.basename(filename)
      @file_size = tempfile.size

      OY::Media::upload_file(name, @extname, tempfile, filename, @type)

      redirect SpecialController.r(:media, "#{name}#{@extname}")
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
