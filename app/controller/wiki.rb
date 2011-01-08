#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

class WikiController < OYController
  map :/

  include OY

  def img(fragments)
    redirect MediaController.r(:img, *fragments)
  end
  
  def index(*fragments)
    key, *arguments = fragments
    "#{key}:  #{arguments.join(",")}"

    methods = public_methods
    if methods.include?(key)
      call(key.to_sym, *arguments)
    else
      begin
        @wiki = repos.find_by_fragments(*fragments)
        if sha = request[:sha]
          unless @wiki.sha == sha
            parent = @wiki
            @wiki = @wiki.history(sha)
            @wiki.parent = parent
          end
        end
        @title = @wiki.title
      rescue NotFound
        redirect WikiController.r(:create, *fragments)
      end
    end
  end

  def history(*fragments)
    @wiki = repos.find_by_fragments(*fragments)
    @wikis = @wiki.history
  end
  
  def edit(*fragments)
    @wiki = repos.find_by_fragments(*fragments)
    @title = @wiki.path
    @action = :update
  end

  def update
    path = request[:path] or raise "no path given"

    redirect WikiController.r(path) unless request.post?
    
    wiki = repos.find_by_fragments(*path.split("/"))
    wiki.update do |pg|
      pg.message = request[:message] || ""
      pg.data    = request[:data]
    end
    redirect WikiController.r(path)
  end

  def new
    path = request[:path] or raise "no path given"
    path = path[1..-1] if path[0..0] == "/"
    wiki = Wiki.create_bare("#{path}.textile")

    wiki.create do |pg|
      pg.message = request[:message]
      pg.data    = request[:data]
    end

    redirect WikiController.r(path)
  rescue AlreadyExist
    redirect WikiController.r(request[:path])
  end
  
  def create(*fragments)
    path = if fragments.empty? then request[:path] else "/#{fragments.join("/")}" end
    redirect WikiController.r if path.to_s.empty?

    # check if page exists
    begin
      wiki = repos.find_by_fragments(*path.split("/"))
    rescue NotFound
    else
      redirect WikiController.r(wiki.path)
    end
    
    @action = :new
    @path = path
    @identifier = File.basename(@path)
  end

  def compare(v1, v2, *fragments)
    begin
      wiki = repos.find_by_fragments(*fragments)
    rescue NotFound
    else
      @data = lines(wiki.diff(v2, v1).first.diff)
    end
  end


  def lines(data)
    lines = []
    data.split("\n")[2..-1].each_with_index do |line, line_index|
      lines << { :line  => line,
        :class => line_class(line),
        :ldln  => left_diff_line_number(0, line),
        :rdln  => right_diff_line_number(0, line) }
    end
    lines
  end

  def line_class(line)
    if line =~ /^@@/
      'gc'
    elsif line =~ /^\+/
      'gi'
    elsif line =~ /^\-/
      'gd'
    else
      ''
    end
  end

  @left_diff_line_number = nil
  def left_diff_line_number(id, line)
    if line =~ /^@@/
      m, li = *line.match(/\-(\d+)/)
      @left_diff_line_number = li.to_i
      @current_line_number = @left_diff_line_number
      ret = '...'
    elsif line[0] == ?-
      ret = @left_diff_line_number.to_s
      @left_diff_line_number += 1
      @current_line_number = @left_diff_line_number - 1
    elsif line[0] == ?+
      ret = ' '
    else
      ret = @left_diff_line_number.to_s
      @left_diff_line_number += 1
      @current_line_number = @left_diff_line_number - 1
    end
    ret
  end

  @right_diff_line_number = nil
  def right_diff_line_number(id, line)
    if line =~ /^@@/
      m, ri = *line.match(/\+(\d+)/)
      @right_diff_line_number = ri.to_i
      @current_line_number = @right_diff_line_number
      ret = '...'
    elsif line[0] == ?-
      ret = ' '
    elsif line[0] == ?+
      ret = @right_diff_line_number.to_s
      @right_diff_line_number += 1
      @current_line_number = @right_diff_line_number - 1
    else
      ret = @right_diff_line_number.to_s
      @right_diff_line_number += 1
      @current_line_number = @right_diff_line_number - 1
    end
    ret
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
