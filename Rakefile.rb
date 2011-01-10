#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


require 'rubygems'
require '../ramaze/lib/ramaze'
require "lib/oy"
require "redcloth"

require "net/http"
require "rspec/core/rake_task"
require "cgi"

include OY

task :test do

  api = OY.api

  d = "h1. Title From Rakefile\n\nsaad fdsfd"
  r = api.post("oldblog/socialwebmeetsrpga") do |opts|
    opts[:author]  = "Api <a@b.c>"
    opts[:data]    = d
    opts[:message] = "Update from Rakefile"
  end

  p r
  exit
  url = 'http://localhost:8200/' 
  uri = URI.parse(url) 
  req = Net::HTTP.new(uri.host, uri.port)
  d = "Lalala Lorem foo bar ipsum dolor adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\n"*3

  data = {
    :message => "update from net/http",
    :extension => "textile",
    :author => CGI.escape("Api <a@b.c>"),
    :data => CGI.escape(d)
  }.inject("") {|mem, arr|
    mem << "%s=%s;" % arr
  }
  data =   result = req.post('/api/PUT/oldblog/socialwebmeetsrpga', data)
  p JSON.parse(result.body)
end

task :create_spec_env do
  sh   "mkdir -p /tmp/testrepos && cd /tmp/testrepos && git init"
  ruby "-r spec/spec_helper.rb spec/mk_specwiki.rb"
end

task :clean do
  File.exist?("/tmp/testrepos") and sh "rm -r /tmp/testrepos"
  File.exist?("coverage") and sh "rm -r coverage"  
end

task :spec => [:clean, :create_spec_env, :run_spec_wo] do
end

task :dry  => [:clean, :create_spec_env]

require "rspec"
RSpec::Core::RakeTask.new(:run_spec) do |t|
  t.pattern = Dir.glob('spec/**/*_spec_*.rb')
  t.rcov_opts  = %q[-Ispec -i spec_helper]
  t.rspec_opts = %q[-f d]
  t.rcov = true
  t.verbose = true
end

RSpec::Core::RakeTask.new(:run_spec_wo) do |t|
  t.pattern = Dir.glob('spec/**/*_spec_*.rb')
  t.rspec_opts = %q[-f d]
  t.rcov = false
end



=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
