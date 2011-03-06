#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require "rubygems"
require "grit"
require "ostruct"
require "nokogiri"
require "json"
require "RedCloth"
require "unicode"

require "pp"

module OY

  Source  = File.dirname(File.dirname(File.expand_path(__FILE__))) unless const_defined?(:Source)

  Actor   = Grit::Actor.new("Anonymous", "anonym@o.us") unless const_defined?(:Actor)

  Version = [0, 4, 5] unless const_defined?(:Version)

  $: << File.join(Source, "lib/oy") unless $:.include?(File.join(Source, "lib/oy"))
  $: << File.join(Source, "app")    unless $:.include?(File.join(Source, "app"))


  Dir["#{Source}/lib/core/**/*.rb"].each do |core_ext|
    require core_ext
  end

  def honeypot_value
    "foobarbaz"
  end
  module_function :honeypot_value

  def self.local?
    @hostname ||= `hostname`
    if @hostname =~ /^xeno/ then true else false end
  end


  def puts(*args)
    args.each do |a|
      begin
        Ramaze::Log.info a
      rescue
        Kernel.puts a
      end
    end
  end
  module_function :puts

  def api(host = nil)
    @api ||= Api.new(host)
  end
  module_function :api

  def path=(str)
    @path = str
  end
  module_function "path="

  def path
    @path || '.'
  end
  module_function :path

  def repos(with_git = true)
    if with_git
      @repos = Repos.new(OY.path)
    else
      @repos = VirtualRepos.new(OY.path)
    end
  end
  module_function :repos

  require "wiki/wikilock"
  require "wiki/wikiindex"
  require "wiki"
  require "wiki/wikidir"
  require "wiki/media"
  require "wiki/physical"
  require "wiki/special"

  require "blob_entry.rb"
  require "git_access.rb"
  require "api.rb"
  require "repos"
  require "exceptions.rb"
  require "markup"
end

=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
