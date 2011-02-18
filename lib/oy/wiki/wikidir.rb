#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module OY

  class WikiDir < Wiki

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

    def exist?
      File.directory?(Repos.expand_path(path))
    end

    def initialize(dir)
      @path = dir
    end

    def cache_key
      @path
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
