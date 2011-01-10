#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "net/http"
require "cgi"

module OY

  class Api
    attr_accessor :host

    def initialize(host = nil)
      @host = host || "http://localhost:8200/"
      @uri  = URI.parse(@host)
      @net  = Net::HTTP.new(@uri.host, @uri.port)
    end

    def post(url)
      options = {}
      yield options
      p options[:message]
      result = @net.post(url_path(url, "POST"), hash_to_data(options))
      JSON.parse(result.body)
    end

    def url_path(url, meth = "GET")
      File.join("/api/#{meth.to_s.upcase}/", *url.split("/"))
    end

    def hash_to_data(hash)
      hash.inject("") {|mem, arr|
        mem << "%s=%s;" % [arr.first, CGI.escape(arr.last)]
      }
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
