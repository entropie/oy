#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


require 'rubygems'
require "net/http"

begin
  require "rspec/core/rake_task"
rescue LoadError
end

require "cgi"
require "date"


task :docs do
  require "lib/oy"
  include OY
  Dir.glob("docs/*").each do |docfile|
    file, ext = docfile.split(".").first
    frags = ["about", *docfile.split("/")[1..-1]]

    fc = File.open(docfile, 'r').read

    begin
      page = repos.find_by_fragments(frags.join("/"))
    rescue NotFound
      page = Wiki.create_bare(frags.join("/"))
    end
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

task :doc => [:clean, :write_doc, :move_doc] do
end

task :move_doc do
  File.exist?("app/public/doc") and sh "rm -r app/public/doc"
  sh "mv doc app/public/doc"
end

RSpec::Core::RakeTask.new(:run_spec) do |t|
  t.pattern = Dir.glob('spec/**/*_spec_*.rb')
  t.rcov_opts  = %q[-Ispec -i spec_helper]
  t.rspec_opts = %q[-f d]
  t.skip_bundler = true
  t.rcov = true
  t.verbose = true
end

RSpec::Core::RakeTask.new(:run_spec_wo) do |t|
  t.pattern = Dir.glob('spec/**/*_spec_*.rb')
  t.rspec_opts = %q[-f d]
  t.skip_bundler = true  
  t.rcov = false
end

require 'rocco/tasks'
require "shellwords"


if Gem.available?("yard")
  require "yard"
  YARD::Rake::YardocTask.new(:write_doc) do |t|
    t.files   = ['lib/**/*.rb', 'app/**/*.rb', 'spec/**/*.rb']
    t.options = ['--title', 'Oy! Documentation', '-o', 'doc/']
  end
else
  task :write_doc do
    str = "rdoc --all --inline-source --line-numbers -f html --template=hanna -o doc"
    str << ' --webcvs=http://github.com/entropie/oy/tree/master/'
    sh str
  end
end


# Stolen from gollum

#############################################################################
#
# Helper functions
#
#############################################################################

def name
  @name ||= Dir['*.gemspec'].first.split('.').first
end

def version
  line = File.read("lib/#{name}.rb")[/^\s*Version\s*=\s*.*/]
  r = eval("[" + line.match(/.*Version\s*=\s*\[(.*)\]/)[1] + "]")
  r.join(".")
end

def date
  Date.today.to_s
end

def rubyforge_project
  name
end

def gemspec_file
  "#{name}.gemspec"
end

def gem_file
  "#{name}-#{version}.gem"
end

def replace_header(head, header_name)
  head.sub!(/(\.#{header_name}\s*= ').*'/) { "#{$1}#{send(header_name)}'"}
end


task :release => :build do
  unless `git branch` =~ /^\* master$/
    puts "You must be on the master branch to release!"
    exit!
  end
  sh "git commit --allow-empty -a -m 'Release #{version}'"
  sh "git tag v#{version}"
  sh "git push origin master"
  sh "git push origin v#{version}"
  sh "gem push pkg/#{name}-#{version}.gem"
end

task :build => :gemspec do
  sh "mkdir -p pkg"
  sh "gem build #{gemspec_file}"
  sh "mv #{gem_file} pkg"
end

task :gemspec => :validate do
  # read spec file and split out manifest section
  spec = File.read(gemspec_file)
  head, manifest, tail = spec.split("  # = MANIFEST =\n")

  
  # replace name version and date
  replace_header(head, :name)
  replace_header(head, :version)
  replace_header(head, :date)
  #comment this out if your rubyforge_project has a different name
  replace_header(head, :rubyforge_project)

  # determine file list from git ls-files
  files = `git ls-files`.
    split("\n").
    sort.
    reject { |file| file =~ /^\./ }.
    reject { |file| file =~ /^(rdoc|pkg)/ }.
    map { |file| "    #{file}" }.
    join("\n")

  # piece file back together and write
  manifest = "  s.files = %w[\n#{files}\n  ]\n"
  spec = [head, manifest, tail].join("  # = MANIFEST =\n")
  File.open(gemspec_file, 'w') { |io| io.write(spec) }
  puts "Updated #{gemspec_file}"
end

task :validate do
  libfiles = Dir['lib/*'] - ["lib/#{name}.rb", "lib/#{name}"]
  unless libfiles.empty?
    puts "Directory `lib` should only contain a `#{name}.rb` file and `#{name}` dir."
    exit!
  end
  unless Dir['VERSION*'].empty?
    puts "A `VERSION` file at root level violates Gem best practices."
    exit!
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
