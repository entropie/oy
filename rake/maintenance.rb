#
#
# Author:  Michael 'manveru' Fellinger https://github.com/manveru/
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

def version_today
  Date.today.strftime("%Y.%m.%d")
end

def version_month
  Date.today.strftime("%Y.%m")
end

namespace :m do
  desc "show a todolist from all the TODO tags in the source"
  task :todo do
    files = Dir['{app,lib,spec}/**/*.rb']

    files.each do |file|
      lastline = todo = comment = long_comment = false

      File.readlines(file).each_with_index do |line, lineno|
        lineno += 1
        comment = line =~ /^\s*?#.*?$/
        long_comment = line =~ /^=begin/
        long_comment = line =~ /^=end/
        todo = true if line =~ /(FIXME|TODO):/ and (long_comment or comment)
        todo = false if line.gsub('#', '').strip.empty?
        todo = false unless comment or long_comment
        if todo
          unless lastline and lastline + 1 == lineno
            Kernel.puts
            Kernel.puts "#{ENV['EDITOR']} +#{lineno} #{file}"
          end

          l = line.strip.gsub(/^#\s*/, '')
          print '  ' unless l =~ /^-/
          Kernel.puts l
          lastline = lineno
        end
      end
    end
  end

  desc "generate doc/TODO from the TODO tags in the source"
  task 'todolist' do
    list = `rake m:todo`
    tasks = {}
    current = nil

    list.split("\n")[2..-1].each do |line|
      if line =~ /TODO/ or line.empty?
      elsif line =~ /^e /
        current = line.split[1]
        tasks[current] = []
      else
        tasks[current] << line
      end
    end

    lines = tasks.map{ |name, items| [name, items, ''] }.flatten
    lines.pop

    File.open(File.join('doc', 'TODO'), 'w+') do |f|
      f.puts "This list is programmaticly generated by `rake maintenance:todolist`"
      f.puts "If you want to add/remove items from the list, change them at the"
      f.puts "position specified in the list."
      f.puts
      f.puts(lines)
    end
  end

  desc "remove those annoying spaces at the end of lines"
  task 'fix-end-spaces' do
    Dir['{lib,spec,app}/**/*.rb'].each do |file|
      lines = File.readlines(file)
      new = lines.dup
      lines.each_with_index do |line, i|
        if line =~ /\s+\n/
          puts "fixing #{file}:#{i + 1}"
          p line
          new[i] = line.rstrip
        end
      end

      unless new == lines
        File.open(file, 'w+') do |f|
          new.each do |line|
            f.puts(line)
          end
        end
      end
    end
  end


  def existing_authors
    authors = {}

    File.readlines('AUTHORS').each do |line|
      if line =~ /\s+(.*?)\s*:\s*(.*@.*)/
        authors[$1] = {:email => $2, :patches => 0}
      end
    end

    authors
  end

  def authors
    format = "%an ** %ae"
    log = `git-log --pretty=format:'#{format}'`
    
    mapping = existing_authors

    log.split("\n").each do |line|
      name, email = line.split(' ** ')

      if name =~ /(\S+@\S+)/
        email ||= $1
        name.sub!(email, '').strip!
      end

      email_start = /^#{Regexp.escape(name)}@(.*)/
      AUTHOR_MAP.each do |e, a|
        if e =~ email_start
          email, name = e, a
          break
        end
      end

      name = AUTHOR_MAP[name] || name
      email = AUTHOR_MAP.index(name) || email

      mapping[name] ||= {:email => email, :patches => 0}
      mapping[name][:patches] += 1
    end

    max = mapping.map{|k,v| k.size }.max
    mapping.inject({}) {|h,(k,v)| h[k.ljust(max)] = v; h}
  end

  desc "Update /doc/AUTHORS"
  task 'authors' do
    # get the authors before we overwrite the file
    authors = authors().sort_by{|k,v| k}

    File.open('AUTHORS', 'w+') do |fp|
      fp.puts "Following persons (in alphabetical order) have contributed to Ramaze:"
      fp.puts
      authors.each do |name, author|
        fp.puts "   #{name}  :  #{author[:email]}"
      end
      fp.puts
    end
  end

  desc "show how many patches we made so far"
  task :patchsize do
    patches = `git rev-list HEAD | wc -l`.to_i
    puts "currently we have #{patches} patches"
    init = Time.parse("Sun Jan 2 23:59:02 2011 +0100")
    days = (Time.now - init) / (3600 * 24)
    Kernel.puts "%d days since init, avg %4.2f patches per day" % [days, patches/days]
  end

  desc "show who made how many patches"
  task :patchstat do
    total = 0.0

    authors.map do |name, hash|
      patches = hash[:patches]
      total += patches
      [patches, name]
    end.sort.reverse_each do |patches, name|
      puts "%s %4d [%6.2f%% ]" % [name, patches, patches/total * 100]
    end
  end

  desc "upload packages to rubyforge"
  task 'release' => ['distribute'] do
    sh 'rubyforge login'
    sh "rubyforge add_release ramaze ramaze #{VERS} pkg/ramaze-#{VERS}.gem"

    require 'open-uri'
    require 'hpricot'

    url = "http://rubyforge.org/frs/?group_id=3034"
    doc = Hpricot(open(url))
    a = (doc/:a).find{|a| a[:href] =~ /release_id/}

    version = a.inner_html
    release_id = Hash[*a[:href].split('?').last.split('=').flatten]['release_id']

    sh "rubyforge add_file ramaze ramaze #{release_id} pkg/ramaze-#{VERS}.tar.gz"
    sh "rubyforge add_file ramaze ramaze #{release_id} pkg/ramaze-#{VERS}.tar.bz2"
  end

  task 'undocumented-module' do
    require 'strscan'
    require 'term/ansicolor'

    $stdout.sync = true

    class String
      include Term::ANSIColor
    end

    class SimpleDoc
      def initialize(string)
        @s = StringScanner.new(string)
      end

      def scan
        comment = false
        total, missing = [], []
        until @s.eos?
          unless @s.scan(/^\s*#.*/)
            comment = true if @s.scan(/^=begin[^$]*$/)
            comment = false if comment and @s.scan(/^=end$/)

            unless comment
              if @s.scan(/(?:class ).*/)
                #p @s.matched
              elsif @s.scan(/(?:module ).*/)
                #p @s.matched
              elsif @s.scan(/(?:[\s$]def\s+)[\w?!*=+\/-]+(?=[\(\s])/)
                total << @s.matched.split.last
                prev = @s.pre_match.split("\n")
                prev.delete_if{|s| s.strip.empty?}
                unless prev.last =~ /^\s*#.*/
                  missing << @s.matched.split.last
                end
              else
                @s.scan(/./m)
              end
            end
          end
        end

        return total, missing
      end
    end

    all = {}
    files = Dir['{app,lib}/**/*.rb']
    ignore = []

    print "scanning ~#{files.size} files "
    files.each do |file|
      next if ignore.any?{|i| file =~ i}
      print "."
      t, m = SimpleDoc.new(File.read(file)).scan
      all[file] = [t, m]
    end
    Kernel.puts " done."

    failed = all.reject{|k,(t,m)| m.size == 0}

    max = failed.keys.sort_by{|f| f.size}.last.size

    colors = {
      (0..25  ) => :blue,
      (25..50 ) => :green,
      (50..75 ) => :yellow,
      (75..100) => :red,
    }

    Kernel.puts "\nAll undocumented methods\n\n"

    failed.sort.each do |file, (t, m)|
      ts, ms = t.size, m.size
      tss, mss = ts.to_s, ms.to_s
      ratio = ((ms.to_f/ts)*100).to_i
      color = colors.find{|k,v| k.include?(ratio)}.last
      complete = ms.to_f/ts.to_f
      mthc = "method"
      if ms > 0
        Kernel.puts "#{file.ljust(max)}\t[#{[mss, tss].join('/').center(8)}]".send(color)
        mthc = "methods" if ts > 1
        if $VERBOSE
          Kernel.puts "Of #{tss} #{mthc}, #{mss} still needs documenting (#{100 - ratio}% documented, #{ratio}% undocumented)".send(color)
          mthc = "method"
          mthc = "methods" if ms > 1
          print "#{mthc.capitalize}: "
        end
        Kernel.puts m.join(', ')
        Kernel.puts
      end
    end

    Kernel.puts "The colors mean percentages of documentation left (ratio of undocumented methods to total):"
    colors.sort_by{|k,v| k.begin}.each do |r, color|
      print "[#{r.inspect}] ".send(color)
    end
    Kernel.puts "", ""

    documented = 0
    undocumented = 0

    all.values.each do |(d,m)|
      documented += d.size
      undocumented += m.size
    end

    total = documented + undocumented
    ratio = (documented * 100.0) / total

    Kernel.puts "Total documented: #{documented}, undocumented: #{undocumented}"
    Kernel.puts "%.2f%% of Ramaze is documented!" % ratio
  end

  desc "list all undocumented methods"
  task 'undocumented' do
    $VERBOSE = false
    Rake::Task['m:undocumented-module'].invoke
  end

  desc "list all undocumented methods verbosely"
  task 'undocumented-verbose' do
    $VERBOSE = true
    Rake::Task['m:undocumented-module'].invoke
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
