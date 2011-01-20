#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


class OYController < Ramaze::Controller
  engine :Haml
  
  layout(:layout) { !request.xhr? } 
  
  IgnoreList = %w'edit create history new compare oy img revert'

  private

  # FIXME:
  def add_repos_paths
    unless Ramaze.options.roots.include?(repos.path)
      puts "_"*60
      
      Ramaze.options.roots.unshift(repos.path)
      [:public, :layout, :view].each do |apath|
        if OY::Repos.exist?("_#{apath}")
          Ramaze.options.send("#{apath}s") << "_#{apath}"
          puts "Ramaze.options.#{apath}s << '_#{apath}s'"
        end
      end
      puts "_"*60      
    end
  end

  def oy_render_file(file, opts = {})
    path_in_repos = File.join("_view", file)
    if OY::Repos.exist?(path_in_repos)
      render_file(OY::Repos.expand_path(path_in_repos), opts)
    else
      render_file(File.join("view", file), opts)
    end
  end

  def create_prefix(arr = false, npath = nil)
    fragments = (npath or request.path).split("/")[1..-1]
    fragments ||= []

    fragments.reject!{|f| f == "."}
    
    if fragments.empty? or fragments.first == "oy"
      return arr ? fragments : ''
    elsif IgnoreList.include?(fragments.first)
      return "" if fragments.first == "revert"
      fragments.shift
    end
    if arr then fragments else
      ret = "#{File.dirname(File.join(*fragments))}/"
      return '' if ret == "./"
      ret
    end
  end

  def page_prefix
    create_prefix(true)[0..-2].map{|prfx| "#{prfx.capitalize} &gt; "}.join
  end
  
  def time_to_s(t)
    t.strftime("%d-%b-%y &mdash; %H:%M")
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
