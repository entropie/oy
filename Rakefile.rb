#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


require 'rubygems'
require '../ramaze/lib/ramaze'
require "lib/oy"
require "redcloth"

require "rspec/core/rake_task"

include OY

task :test do
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
