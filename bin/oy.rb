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

help = "Oy!: lalal\nlala\n"

default_options = {
  :port => 8200,
  :hostname => "localhost",
  :repos    => "."
}

opts = OptionParser.new do |opts|

  opts.banner = help

  opts.on("-h", "--hostname [HOST]", "hostname") do |hn|
    default_options[:hostname] = hn
  end
  
  opts.on("-r", "--repos [REPOS]", "Start oy with with [REPOS]") do |repos|
    repos_path = File.expand_path(repos)
    raise OY::NotFound unless File.exist?(repos_path)
    default_options[:repos] = repos
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

begin
  OY.path = default_options[:repos]
  require "start"
  Dir.chdir(File.join(OY::Source, "app")) do
    Ramaze.start(:host => default_options[:hostname], :port => 8200)
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
