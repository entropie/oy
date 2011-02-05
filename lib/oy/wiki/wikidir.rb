#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module OY

  class WikiDir < Wiki

    include WikiLock

    def lockdir_path
      check = Repos.expand_path(path)
      File.join(path, ".locked")
    end

    def lock!
      lock_directory!
      # FIXME: ???
      Dir.chdir(repos.path){ repos.git.git.checkout({}, 'HEAD', '--', lockdir_path) }
      true
    end

    def unlock!
      update_repos_lockfiles(:delete, lockdir_path)
      # FIXME:
      Dir.chdir(repos.path){ repos.git.git.rm({:f => true}, 'HEAD', '--', lockdir_path) }
      true
    end

    def identifier
      path
    end

    # FIXME:
    def [](obj)
      page_path = path + "/#{obj.to_s}"
      repos.find_by_fragments(*page_path.split("/"))
    end

    def pages(only_pages = true)
      rpath = Repos.expand_path(path)
      files = Dir.entries(rpath)
      ret = files.map{|f|
        next if f =~ /^\.+/
        frags = f.split("/")
        begin
          repos.find_by_fragments(*frags)
        rescue NotFound
          repos.find_directory(*frags) unless only_pages
        end
      }.compact

      ret
    end

    def exist?
      File.directory?(Repos.expand_path(path))
    end

    def initialize(dir)
      @path = dir
    end

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
