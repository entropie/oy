#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module OY

  module Markup

    class Compare < Markup

      def initialize()
      end
      
      self.extension = "compare"

      def to_html(data)
        lines(data)
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
