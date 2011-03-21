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
help = "#{$0}: Simple Blog controller for the Oy! wiki.\n\n"


module OY
  module BlogCtrl

    class << self
      attr_accessor :blog_source, :blog_uri, :namespace, :commit_msg, :page_title

      def action_handler
        @action_handler ||= BlogActions.new(blog_source, blog_uri)
      end

      def parse_actions(*actions)
        action_handler.process(actions)
      end
    end

    def oy_path(path)
      File.join(BlogCtrl.namespace, path)
    end

    def oy_path_with_tstamp(path, timefmt = "%Y/%W")
      oy_path("%s-%s" % [Time.now.strftime(timefmt), path])
    end

    def wrap_data(title = nil)
      t = Time.now
      title ||= "Collection for week <em>#{t.strftime("%W")}</em>"
      str = "h1. #{title}\n\n<div id='tlog-page'>\n\n"
      str << yield
      str << "\n\n</div>"
    end

    class BlogActions

      include BlogCtrl

      attr_reader :source, :uri

      def initialize(blog_source, blog_uri)
        @source, @uri = blog_source, blog_uri
      end

      def api
        @api ||= Api.new(uri)
      end

      def result
        @result ||= ''
      end

      def process(actions)
        actions.each do |action|
          result << send(action) << "\n"
        end
        @result
      end

      def current_file
        file = File.join(source, "current.textile")
        raise NotFound, "'#{file}' does not exist" unless File.exist?(file)
        file
      end

      ### actions
      def show_current
        File.readlines(current_file).join
      end

      def sync_current
        path = oy_path_with_tstamp("collection")
        apost = api.post(path) do |opts|
          opts[:author]  = "Michael 'entropie' Trommer <mictro@gmail.com>"
          opts[:markup]  = "textile"
          opts[:data]    = wrap_data(BlogCtrl.page_title){ File.readlines(current_file).join }
          opts[:message] = BlogCtrl.commit_msg
        end
        PP.pp(apost, '')
      end
    end

  end
end

include OY

default_options = {
  :blog_uri     => "http://localhost:8200",
  :blog_source  => File.expand_path("~/.blog"),
  :namespace    => "tlog",
  :actions      => [],
  :commit_msg   => "Synced draft file.",
  :page_title   => nil
}

opts = OptionParser.new do |opts|

  opts.banner = help

  opts.on(nil, "--blog-source [PATH]",
          "Path to local blog directory (Default is '~/.blog'") do |bsp|
    path = File.expand_path(bsp)
    raise NotFound, "'#{bsp}' does not exist" unless File.exist?(path)
    default_options[:blog_source] = path
  end

  opts.on(nil, "--oy-namespace [NAMESPACE]",
          "Namespace for Oy! Wiki (the path where the page will live, default is 'tlog')") do |ns|
    default_options[:namespace] = ns
  end

  opts.on("-t", "--page-title [TITLE]",
          "The Title for the page (only in combination with -s)") do |title|
    default_options[:page_title] = title
  end

  opts.on("-m", "--message [MSG]",
          "Commit Message (only in combination with -s)") do |msg|
    default_options[:commit_msg] = msg
  end

  opts.on("-c", "--current",
          "Prints contents from current.textile") do
    default_options[:actions] << :show_current
  end

  opts.on("-s", "--sync",
          "Sends current.textile to Oy!") do
    default_options[:actions] << :sync_current
  end

end


begin
  opts.parse!
rescue OptionParser::InvalidOption
  puts "oyblog: #{$!.message}"
  puts "oyblog: try 'oy --help' for more information"
  exit 1
end


%w'blog_source blog_uri namespace commit_msg page_title'.map{|a| a.to_sym }.each do |arg|
  BlogCtrl.send("#{arg}=", default_options[arg])
end

puts BlogCtrl.parse_actions(*default_options[:actions]).strip


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
