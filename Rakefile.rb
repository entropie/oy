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
  r = api.post("lalalalala") do |opts|
    opts[:author]  = "Api <a@b.c>"
    opts[:data]    = d
    opts[:message] = "Update from Rakefile"
  end
  p r
end

task :create_spec_env do
  sh   "mkdir -p /tmp/testrepos && cd /tmp/testrepos && git init"
  ruby "-r spec/spec_helper.rb spec/mk_specwiki.rb"
end

task :clean do
  File.exist?("/tmp/testrepos") and sh "rm -r /tmp/testrepos"
  File.exist?("coverage") and sh "rm -r coverage"
  File.exist?("app/public/doc") and sh "rm -r app/public/doc"  
end

task :spec => [:clean, :create_spec_env, :run_spec_wo] do
end

task :dry  => [:clean, :create_spec_env]

task :rdoc => [:clean, :write_rdoc, :move_rdoc] do
end

task :move_rdoc do
  File.exist?("app/public/doc") and sh "rm -r app/public/doc"
  sh "mv doc app/public/doc"
end


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

#require 'hanna/rdoctask'

task :write_rdoc do
  str = "rdoc --all --inline-source --line-numbers -f html --template=hanna -o doc"
  str << ' --webcvs=http://github.com/entropie/oy/tree/master/'
  sh str
end


# Rake::RDocTask.new(:write_rdoc) do |rdoc|
#   rdoc.rdoc_files.
#     include('**/*.rb')

#   rdoc.main = "README.rdoc" # page to start on
#   #rdoc.title = "will_paginate documentation"

#   rdoc.rdoc_dir = 'doc' # rdoc output folder
#   rdoc.options << '--webcvs=http://github.com/entropie/oy/tree/master/'
#end

=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
