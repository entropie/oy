# -*- coding: undecided -*-

module Rack

  # based on
  # https://github.com/sunlightlabs/rack-honeypot
  class Honeypot

    include OY

    def initialize(app, options={})
      @app = app
      @class_name   = options[:class_name]  || "pemail"
      @label        = options[:label]       || "Don't fill in this field"
      @input_name   = options[:input_name]  || "pemail"
      @input_value  = options[:input_value] || honeypot_value
    end

    def call(env)
      if spambot_submission?(Rack::Request.new(env).params)
        path = env["rack.request.form_hash"]["path"]
        puts "***SPAM*** send to nowhere ('%s' : '%s') ***SPAM***" % [env["REMOTE_ADDR"], path]
        send_to_dead_end
      else
        status, headers, response = @app.call(env)
        new_body = insert_honeypot(build_response_body(response))
        new_headers = recalculate_body_length(headers, new_body)
        [status, new_headers, new_body]
      end
    end

    def spambot_submission?(form_hash)
      form_hash && form_hash[@input_name] && form_hash[@input_name] != @input_value
    end

    def send_to_dead_end
      [200, {'Content-Type' => 'text/html', "Content-Length" => "0"}, []]
    end

    def build_response_body(response)
      response_body = ""
      response.each { |part| response_body += part }
      response_body
    end

    def recalculate_body_length(headers, body)
      new_headers = headers
      new_headers["Content-Length"] = body.length.to_s
      new_headers
    end

    def insert_honeypot(body)
      css = <<-BLOCK
        <style type='text/css' media='all'>
          div.#{@class_name} {
            display:none;
          }
        </style>
      BLOCK
      div = <<-BLOCK
        <div class='#{@class_name}'>
          <label for='#{@input_name}'>#{@label}</label>
          <input type='text' name='#{@input_name}' value='#{@input_value}'/>
        </div>
      BLOCK
      body.gsub!(/<\/head>/, css.unindent + "\n</head>")
      body.gsub!(/<form(.*)>/, '<form\1>' + "\n" + div.unindent)
      body
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
