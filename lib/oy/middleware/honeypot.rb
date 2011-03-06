# -*- coding: undecided -*-

module Rack

  # based on
  # https://github.com/sunlightlabs/rack-honeypot
  class Honeypot

    include OY

    unless const_defined?(:CLASS_NAME)
      CLASS_NAME  = "pemail"
      LABEL       = "Don't fill in this field"
      INPUT_NAME  = "pemail"
      INPUT_VALUE = OY.honeypot_value
    end

    def initialize(app, options={})
      @app = app
      @class_name   = CLASS_NAME
      @label        = LABEL
      @input_name   = INPUT_NAME
      @input_value  = INPUT_VALUE
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

    def self.honeypot
      %Q"<div class='#{CLASS_NAME}'><label for='#{INPUT_NAME}'>#{LABEL}</label>" +
        %Q"<input type='text' name='#{INPUT_NAME}' value='#{INPUT_VALUE}'/></div>"
    end

    def insert_honeypot(body)
      css = <<-BLOCK
        <style type='text/css' media='all'>
          div.#{@class_name} {
            display:none;
          }
        </style>
      BLOCK
      body.sub!(/<\/head>/, css.unindent + "\n</head>")
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
