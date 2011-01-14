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

opts = OptionParser.new do |opts|

  opts.banner = help

  opts.on("-r", "--repos [REPOS]", "Start oy with with [REPOS]") do |repos|
    repos_path = File.expand_path(repos)
    raise OY::NotFound unless File.exist?(repos_path)
    Dir.chdir("../app") do
      OY.path = repos_path
      require "start"
      Ramaze.start(:host => "localhost", :port => 8200)
    end
  end
  
  opts.on("-p", "--push [TO]", "Push Piped Data to [URL]") do |to|
    raise InvalidInput, "No Destination URL given" unless to
    raise InvalidInput, "No Data Given (use a pipe)" if inputData.to_s.strip.empty?

    inputData = STDIN.read

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
  puts "oy: try 'oy --help' for more information"
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
