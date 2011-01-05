#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class MediaController < OYController
  map "/media"

  engine :None
  set_layout_except 'layout' => [:img]

  def img(*fragments)
    if request[:p]
      redirect SpecialController.r(:media, :img, *fragments)
    else
      file_path = File.join(MediaPath, *fragments)
      content_type ||= Rack::Mime.mime_type(::File.extname(file_path))
      response['Content-Length'] = ::File.size(file_path).to_s
      response["Content-Type"] = "image/jpeg"
      File.open(file_path, 'rb').read
    end
    
  end
  

  def upload
    if request.post?
      name = request[:name]
      tempfile, filename, @type = request[:file].
        values_at(:tempfile, :filename, :type) 

      @extname, @basename = File.extname(filename), File.basename(filename) 
      @file_size = tempfile.size

      OY::Media::upload_file(name, @extname, tempfile, filename, @type)

      redirect "/media/img/#{name}#{@extname}"
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
