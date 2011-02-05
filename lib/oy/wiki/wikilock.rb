#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module OY

  module WikiLock

    def lockfile_path
      check = Repos.expand_path(path)
      path + ".locked"
    end

    def lockdir_path
      check = Repos.expand_path(path)
      File.join(File.dirname(path), '.locked')
    end

    def locked?
      File.exist?(Repos.expand_path(lockfile_path)) or
        File.exist?(Repos.expand_path(lockdir_path))
    end

    def lock!
      FileUtils.touch(Repos.expand_path(lockfile_path))
      update_repos_lockfiles(:add, lockfile_path)
      true
    end

    def lock_directory!
      FileUtils.touch(Repos.expand_path(lockdir_path))
      update_repos_lockfiles(:add, lockdir_path)
      true
    end

    def unlock!
      # check if file is locked, not the parent directory
      raise FileNotLocked unless File.exist?(Repos.expand_path(lockfile_path))

      update_repos_lockfiles(:delete, lockfile_path)
      true
    end

    def unlock_directory!
      update_repos_lockfiles(:delete, lockdir_path)
      true
    end

    def revert_to(*args)
      raise FileLocked, "file is locked" if locked?
      super(*args)
    end

    def update
      raise FileLocked, "file is locked" if locked?
      super
    end

    def update_repos_lockfiles(what, *files)
      index = nil

      opts = OpenStruct.new
      dir = ::File.dirname(path)
      dir = "" if dir == "."

      files.each do |file|
        opts.message = "#{what}: #{file}"

        sha = commit_index(opts) do |idx|
          index = idx
          case what
          when :add
            index.send(what, file, "")
            update_working_dir(index, dir, "", file)
          when :delete
            index.send(what, file)
            Dir.chdir(repos.path) do
              repos.git.git.rm({:f => true}, '--', file)
              FileUtils.rm(file) rescue Errno::ENOENT
            end
          end
        end
      end
      true
    end
    private :update_repos_lockfiles

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
