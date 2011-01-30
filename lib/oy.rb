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

  Version = [0, 3, 3] unless const_defined?(:Version)
  
  $: << File.join(Source, "lib/oy") unless $:.include?(File.join(Source, "lib/oy"))
  $: << File.join(Source, "app")    unless $:.include?(File.join(Source, "app"))


  Dir["#{Source}/lib/core/**/*.rb"].each do |core_ext|
    require core_ext
  end
  
  def self.local?
    @hostname ||= `hostname`
    if @hostname =~ /^xeno/ then true else false end
  end
  
  def puts(*args)
    args.each do |a|
      Kernel.puts "  |> #{a}"
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

  require "model/git"

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
