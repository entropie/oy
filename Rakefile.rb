#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


require 'rubygems'
#require '../ramaze/lib/ramaze'
require "ramaze"
require "lib/oy"
require "redcloth"

require "net/http"
require "rspec/core/rake_task"
require "cgi"

include OY

task :docs do
  Dir.glob("docs/*").each do |docfile|
    file, ext = docfile.split(".").first
    frags = ["about", *docfile.split("/")[1..-1]]

    fc = File.open(docfile, 'r').read

    begin
      page = repos.find_by_fragments(frags.join("/"))
    rescue NotFound
      page = Wiki.create_bare(frags.join("/"))
    end
    puts "Update: >>> #{page.path}"
    page = page.update do |pg|
      pg.data = fc
      pg.message = "Update Docfile"
      pg.actor = Grit::Actor.new("Michael Trommer", "mictro@gmail.com")
    end
  end
end

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

task :keke do
  shstr = "rake clean create_spec_env; rspec -f d -Ispec"
  Dir.glob('spec/**/*_spec_*.rb').each do |specfile|
    sh "#{shstr} #{specfile}"

    raise ">>> #{specfile}" if File.exist?(File.join(Dir.pwd, 'bar'))
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
