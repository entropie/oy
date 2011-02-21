#!/usr/bin/env ruby
#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "rubygems"
require "optparse"
require "pp"

$:.unshift File.join(File.dirname(__FILE__), "../lib")
$:.unshift File.join(File.dirname(__FILE__), "../app")

require "oy"

help = "Oy!: I want to snu-snu Git -- Oy is a Wiki build on top of Git and grit.\n\n"

default_options = {
  :port     => 8200,
  :hostname => "localhost",
  :repos    => File.expand_path("."),
  :adapter  => :webrick,
  :elog     => File.join(OY::Source, "log", "error_log.log")
}

opts = OptionParser.new do |opts|

  opts.banner = help

  opts.on("-d", "--daemon [start|stop|restart]", "Daemonizes Oy. Default argument is 'start'") do |arg|
    arg ||= "start"
    default_options[:daemon] = arg
  end

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

require "start"
require "oy/app"


# FIXME: this stuff needs to live in oy/oy.rb
begin
  OY.path = default_options[:repos]

  # FIXME:
  $VERBOSE = nil # turn off sass deprecation warnings

  Config.setup do |cfg|
    cfg.repos               = default_options[:repos]
    cfg.adapter             = default_options[:adapter]
    cfg.server["address"]   = default_options[:hostname]
    cfg.server["port"]      = default_options[:port]
    cfg.server["error_log"] = default_options[:elog]
    cfg.server["daemon"]    = default_options[:daemon]
  end

  if [nil, "start"].include?(Config.server["daemon"]) and File.expand_path(OY.path) == File.expand_path(Dir.pwd)
    puts "Your repos path isset to '#{Dir.pwd}', please specify a Repos (-r /path/to/repos) or press RET to use `pwd`."
    STDIN.readline
  end

  module OY::App
    trait[:mode] = OY.local? ? :devel : :production
    what = Config.server["daemon"] || :run
    send(what)
  end

  #   [:layout, :public, :view].each do |opt|
  #     if OY::Repos.exist?("_#{opt}")
  #       puts "Ramaze.options[:#{opt}s] << _#{opt}"
  #       ropts.get("#{opt}s".to_sym)[:value].unshift "_#{opt}"
  #     end
  #   end

  # Ramaze::Cache.options do |cache|
  #   cache.names = [:pages]
  #   cache.default = Ramaze::Cache::MemCache
  # end

  #Innate::View.options.read_cache = true
end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
