#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#


class OYController < Ramaze::Controller
  engine :Haml

  layout(:layout) { !request.xhr? }

  helper :cache

  include OY

  IgnoreList = %w'edit create history new compare oy img revert'

  private

  def store_page(key, page, t)
    info_str = "!!! STORE CACHE: %s: #{page.ident}"
    other_ident = "#{page.ident}.#{page.extension}"
    if other_ident != key and key !~ WikiIndex.indexpage_re
      cache.store(other_ident, [page, t])
      puts info_str % other_ident
    end
    puts info_str % key
    cache.store(key, [page, t])
  end

  def find_or_store_page(fragments)
    ret = []
    wiki, time = nil, nil

    fragments.pop if fragments.last == "index"
    key = Wiki.mk_cache_key_from_fragments(*fragments)

    wiki, time = cache[key]
    if wiki
      puts "!!! USE CACHE: #{PP.pp(key, '').strip}: #{wiki.ident}" if wiki
      return [wiki, time]
    else
      is_dir = maybe_dir = repos.directory(fragments.join("/"))
      # if directory is requested look for index page
      if maybe_dir
        page = maybe_dir.index_page
        page.redirected_from << maybe_dir
      else
        page = repos.find_by_fragments(*fragments)
      end
      store_page(key, page, Time.now)
    end
  end

  # This is a wrapper function for Repos#find_by_fragments which caches
  def find_by_fragments(*frags)
    fragments = frags.dup
    wiki, time = find_or_store_page(frags)
    [wiki, time, true]
  end

  # This is a wrapper function for Repos#find_by_path which caches
  def find_by_path(path)
    path = path.dup

    cache_key = path

    wiki, time = cache[cache_key]
    if wiki
      puts "!!! USE CACHE: #{PP.pp(wiki.cache_key, '').strip}: #{wiki.ident}"
      [wiki, time, true]
    else
      page = repos.find_by_path(path)
      puts "!!! CREATE CACHE: #{PP.pp(page.cache_key, '').strip}: #{page.ident}"
      cache.store(cache_key, [page, t = Time.now])
      [page, t, false]
    end
  end

  # Shortcut to ramaze cache
  def cache
    Ramaze::Cache.cache_helper_value
  end

  # FIXME:
  def add_repos_paths
    unless Ramaze.options.roots.include?(repos.path)
      puts "_"*60

      Ramaze.options.roots.unshift(repos.path)
      [:public, :layout, :view].each do |apath|
        if OY::Repos.exist?("_#{apath}")
          Ramaze.options.send("#{apath}s") << "_#{apath}"
          puts "Ramaze.options.#{apath}s << '_#{apath}'"
        end
      end
      puts "_"*60
    end
  end

  # Chooses whether the file should be rendered from the repos +_view/+ or
  # the one provided by Oy!
  def oy_render_file(file, opts = {})
    path_in_repos = File.join("_view", file)
    if OY::Repos.exist?(path_in_repos)
      render_file(OY::Repos.expand_path(path_in_repos), opts)
    else
      render_file(File.join(OY::Source, "app", "view", file), opts)
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
      return "" if fragments.first == "compare"
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
    t.strftime("%d-%b-%y &mdash; %H:%M") rescue ""
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
