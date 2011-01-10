#!/usr/bin/env ruby
#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "rubygems"
require "optparse"
require "grit"
require "../lib/oy"

help = "Oy!: lalal\nlala\n"


default_options = {
  :actor => Grit::Actor.new("Michael Trommer", "mictro@gmail.com")
}

inputData = STDIN.read

opts = OptionParser.new do |opts|

  opts.banner = help

  opts.on("-p", "--push [TO]", "Push Piped Data to [TOURL]") do |to|
    raise InvalidInput, "No Destination URL given" unless to
    raise InvalidInput, "No Data Given (use a pipe)" if inputData.to_s.strip.empty?

    uri = URI.parse(to)
    host = uri.host
    path = uri.path[1..-1]
    
    api = OY.api("http://#{host}")
    r = api.post(path) do |opts|
      opts[:author]  = "Michael Trommer <mictro@gmail.com>"
      opts[:data]    = inputData
      opts[:message] = "Pushed from Other Oy! Wiki!"
    end
    p r
  end
  
end


begin
  opts.parse!
rescue OptionParser::InvalidOption
  puts "oy: #{$!.message}"
  puts "oy: try 'gollum --help' for more information"
  exit 1
end

=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
