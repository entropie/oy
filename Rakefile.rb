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

require "lib/oy"

require "rake/maintenance.rb"
include OY

OY.path = "/Users/mit/Source/oytest"

task :todo_to_page do
  def mk_class(line)
    csscls =
      case line[/\{(.{1})\}/, 1]
      when "*" then :todo_done
      when "-" then :todo_canceled
      else
        :todo_default
      end
    %Q[(#{csscls})]
  end

  contents = File.readlines("TODO.howm")
  title = "h1. %s\n\n" % contents.shift.delete("=").strip
  str = "#{title}Generated at <i>#{Time.now}</i> from <em>TODO.howm</em>\n\n\n"
  contents.reject!{|line| line.strip.empty? or line =~ /^<<</}


  last = 0
  contents.each do |line|
    prefixs = line.scan(/^\s+/).first.size rescue 0
    listr = "*#{mk_class(line)} %s"

    line = line.gsub(/(\{.{1}\}\s+)/, '').strip

    if prefixs == 2 and last == 0
      str << "*#{listr}\n" % line
    elsif last == 2 and prefixs == 0
      #str << "\n" % line
    elsif last == 0 and prefixs > 0
      str << (" "*(prefixs-2)) << line << "\n"
    else
      str << (listr % line) << "\n"
    end
    last = prefixs
  end
  str << "\n\n"


  path = "about/todo.textile"
  begin
    bwiki = Wiki.create_bare(path)
  rescue AlreadyExist
    bwiki = repos.find_by_fragments(*path.split("/"))
  end
  wiki = bwiki.create do |pg|
    pg.message = "From RakeTask"
    pg.data    = str.strip
    pg.actor   = OY::Actor
  end
end


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

desc "Creates the wiki for testing"
task :create_spec_env do
  sh   "mkdir -p /tmp/testrepos && cd /tmp/testrepos && git init"
  ruby "-r spec/spec_helper.rb spec/mk_specwiki.rb"
end

desc "cleans all files created by rdoc"
task :clean do
  File.exist?("/tmp/testrepos") and sh "rm -r /tmp/testrepos"
  File.exist?("coverage") and sh "rm -r coverage"
  File.exist?("app/public/doc") and sh "rm -r app/public/doc"  
end

desc "Runs the spec (simple)"
task :spec => [:clean, :create_spec_env, :run_spec_wo] do
end


desc "Cleans the repos, writes and moves doc to app/public, runs the specs and synces to publicwiki"
task :spec_to_public => [:clean, :write_doc, :move_doc,
                         :create_spec_env, :run_spec_to_file, :move_coverage, :sync_rdoc_to_public_wiki] do
end


desc "Cleans everything and creates the spec env"
task :dry  => [:clean, :create_spec_env]

desc "creates docs and synces to public wiki"
task :doc => [:clean, :write_doc, :move_doc, :sync_rdoc_to_public_wiki] do
end

desc "moves doc to app/public"
task :move_doc do
  File.exist?("app/public/doc") and sh "rm -r app/public/doc"
  sh "mv doc app/public/doc"
end

desc "moves coverage to app/public/doc"
task :move_coverage do
  sh "mv coverage app/public/doc/"
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

RSpec::Core::RakeTask.new(:run_spec_to_file) do |t|
  t.pattern = Dir.glob('spec/**/*_spec_*.rb')
  t.rcov_opts  = %q[-Ispec -i spec_helper -x /Library/]
  t.rspec_opts = %q[-f h -o app/public/spec.html]
  t.skip_bundler = true
  t.rcov = true
  t.verbose = true
end



if Gem.available?("yard")
  require "yard"
  YARD::Rake::YardocTask.new(:write_doc) do |t|
    t.files   = ['lib/**/*.rb', 'app/**/*.rb', 'spec/**/*.rb']
    t.options = ['--title', 'Oy! Documentation', '-o', 'doc/', '--protected', '--private']
  end
else
  task :write_doc do
    str = "rdoc --all --inline-source --line-numbers -f html -o doc"
    str << ' --webcvs=http://github.com/entropie/oy/tree/master/'
    sh str
  end
end

desc "Syncs doc to public wiki"
task :sync_rdoc_to_public_wiki do |t|
  if File.exist?("rsync.txt")
    sh File.readlines("rsync.txt").join
  end
end

task :sync => :sync_rdoc_to_public_wiki


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
  #sh "gem push pkg/#{name}-#{version}.gem"
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
  libfiles = Dir['lib/*'] - ["lib/#{name}.rb", "lib/#{name}", "lib/core"]
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
