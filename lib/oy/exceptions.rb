#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module OY

  class NotFound < Exception
  end

  class NotAllowed < Exception
  end

  class AlreadyExist < Exception
  end

  class IllegalAccess < Exception
  end

  class FileLocked < Exception
  end

  class FileNotLocked < Exception
  end

  class AmbiguousChoice < Exception
  end

  # Spam!
  class DieFucker < Exception
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
