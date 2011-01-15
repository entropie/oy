#!/usr/bin/env ruby
#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "rubygems"
require "optparse"
require "grit"
require "pp"

$:.unshift File.join(File.dirname(__FILE__), "../lib")
$:.unshift File.join(File.dirname(__FILE__), "../app")

require "oy"

help = "Oy!: The Simple Git-based Wiki\n\n"

default_options = {
  :port => 8200,
  :hostname => "localhost",
  :repos    => File.expand_path(".")
}

opts = OptionParser.new do |opts|

  opts.banner = help

  opts.on("-p", "--port [PORT]", "Application port (default 8200)") do |port|
    default_options[:port] = port.to_i
  end
  
  opts.on("-h", "--hostname [HOST]", "Application hostname (default localhost)") do |hn|
    default_options[:hostname] = hn
  end
  
  opts.on("-r", "--repos [REPOS]", "Start oy with with [REPOS] (default is `pwd`)") do |repos|
    repos_path = File.expand_path(repos)
    raise OY::NotFound unless File.exist?(repos_path)
    default_options[:repos] = repos_path
  end
  
  opts.on("-P", "--push [TO]", "Push Piped Data to [URL]") do |to|
    raise InvalidInput, "No Destination URL given" unless to
    inputData = STDIN.read
    raise InvalidInput, "No Data Given (use a pipe)" if inputData.to_s.strip.empty?    

    uri = URI.parse(to)
    host = uri.host
    path = uri.path[1..-1]

    api = OY.api("#{uri.scheme}://#{host}:#{uri.port}")
    r = api.post(path) do |opts|
      opts[:author]  = "Michael Trommer <mictro@gmail.com>"
      opts[:data]    = inputData
      opts[:message] = "Pushed via Api"
    end
    p r
    exit 0
  end
  
end


begin
  opts.parse!
rescue OptionParser::InvalidOption
  puts "oy: #{$!.message}"
  puts "oy: try 'oy --help' for more information"
  exit 1
end


begin
  OY.path = default_options[:repos]
  require "start"
  Dir.chdir(File.join(OY::Source, "app")) do
    Ramaze.start(:host => default_options[:hostname], :port => default_options[:port])
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
