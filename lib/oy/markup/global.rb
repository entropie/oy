#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module OY

  module Markup

    class Processors < Array
    end


    class Global < Markup

      self.extension = "*"

      def self.processors
        @processors ||= Processors.new
      end

      def initialize(data, wiki = nil)
        super
        @codemap = {}
      end

      def self.is_virtual?
        true
      end

      # Extract all tags into the tagmap and replace with placeholders.
      #
      # data - The raw String data.
      #
      # Returns the placeholder'd String data
      #
      # From Gollum: lib/gollum/markup.rb
      def extract_tags!
        @tagmap = {}
        data.gsub!(/(.?)\[\[(.+?)\]\]([^\[]?)/m) do
          if $1 == "'" && $3 != "'"
            "[[#{$2}]]#{$3}"
          elsif $2.include?('][')
            if $2[0..4] == 'file:'
              pre = $1
              post = $3
              parts = $2.split('][')
              parts[0][0..4] = ""
              link = "#{parts[1]}|#{parts[0].sub(/\.org/,'')}"
              id = Digest::SHA1.hexdigest(link)
              @tagmap[id] = link
              "#{pre}#{id}#{post}"
            else
              $&
            end
          else
            id = Digest::SHA1.hexdigest($2)
            @tagmap[id] = $2
            "#{$1}#{id}#{$3}"
          end
        end
        nil
      end

      # Process all tags from the tagmap and replace the placeholders with the
      # final markup.
      #
      # data      - The String data (with placeholders).
      #
      # Returns the marked up String data.
      #
      # From Gollum: lib/gollum/markup.rb
      def process_tags(data)
        @tagmap.each do |id, tag|
          data.gsub!(id, process_tag(tag))
        end
        data
      end

      # Process a single tag into its final HTML form.
      #
      # tag       - The String tag contents (the stuff inside the double
      #             brackets).
      #
      # Returns the String HTML version of the tag.
      #
      # From Gollum: lib/gollum/markup.rb
      def process_tag(tag)
        ret = ''
        self.class.processors.each do |processor|
          res = send(processor, tag)
          if res
            ret = res
            break
          end
        end
        ret
      end

      GIST_URL = 'https://gist.github.com/%s.js'
      class << self
        attr_accessor :gist_url
        def gist_url
          @gist_url || GIST_URL
        end
      end

      processors << :process_gist_tag
      def process_gist_tag(tag)
        gistid = nil
        if tag =~ /^gist\s+([0-9]+)/ || tag =~ /https:\/\/gist\.github\.com\/([0-9]+)/
          gistid = $1.to_i
        else
          return false
        end
        cssid = "oy-gist#{gistid}"
        gistjs = %Q(<div class="oy-gist" id="#{cssid}"><script onload="$('#{cssid}').setupGistScrollbar()" src="%s"></script></div>) % [ self.class.gist_url % gistid ]
        gistjs
      end

      # Parse any options present on the image tag and extract them into a
      # Hash of option names and values.
      #
      # tag - The String tag contents (the stuff inside the double brackets).
      #
      # Returns the options Hash:
      #   key - The String option name.
      #   val - The String option value or true if it is a binary option.
      def parse_image_tag_options(tag)
        tag.split('|')[1..-1].inject({}) do |memo, attr|
          parts = attr.split('=').map { |x| x.strip }
          memo[parts[0]] = (parts.size == 1 ? true : parts[1])
          memo
        end
      end

      # returns the filename if +name+ exist in the repos or nil
      def media_file_exist?(name)
        expaned_path =
          File.join(Media.media_path, name.gsub(/img\//, ''))
        File.exist?(expaned_path) and name
      end
      private :media_file_exist?

      processors << :process_image_tag
      # Attempt to process the tag as an image tag.
      #
      # tag - The String tag contents (the stuff inside the double brackets).
      #
      # Returns the String HTML if the tag is a valid image tag or nil
      #   if it is not.
      #
      # From Gollum: lib/gollum/markup.rb, modified
      def process_image_tag(tag)
        parts = tag.split('|')
        return if parts.size.zero?

        name  = parts[0].strip

        path  = if file = media_file_exist?(name)
                  file
                elsif name =~ /^https?:\/\/.+(jpg|png|gif|svg|bmp)$/i
                  name
                end

        if path
          opts = parse_image_tag_options(tag)
          containered = false

          classes = [] # applied to whatever the outermost container is
          attrs   = [] # applied to the image

          align = opts['align']
          if opts['float']
            containered = true
            align ||= 'left'
            if %w{left right}.include?(align)
              classes << "float-#{align}"
            end
          elsif %w{top texttop middle absmiddle bottom absbottom baseline}.include?(align)
            attrs << %{align="#{align}"}
          elsif align
            if %w{left center right}.include?(align)
              containered = true
              classes << "align-#{align}"
            end
          end

          if width = opts['width']
            if width =~ /^\d+(\.\d+)?(em|px)$/
              attrs << %{width="#{width}"}
            end
          end

          if height = opts['height']
            if height =~ /^\d+(\.\d+)?(em|px)$/
              attrs << %{height="#{height}"}
            end
          end

          if alt = opts['alt']
            attrs << %{alt="#{alt}"}
          end

          attr_string = attrs.size > 0 ? attrs.join(' ') + ' ' : ''

          if opts['frame'] || containered
            classes << 'frame' if opts['frame']
            %{<span class="#{classes.join(' ')}">} +
              %{<span>} +
              %{<img src="#{path}" #{attr_string}/>} +
              (alt ? %{<span>#{alt}</span>} : '') +
              %{</span>} +
              %{</span>}
          else
            %{<img src="#{path}" #{attr_string}/>}
          end
        end
      end

      # makes a html link for given +url+
      # If +title+ is +nil get the name from OY::Markup::markup_abbrevs
      # by the exteions of the file.
      # If this fails it returns a link with title "NIL"
      def mk_link(url, css, title)
        abbrev_title = title.nil? ? OY::Markup.markup_abbrevs[File.extname(url)[1..-1].to_sym] : title
        %Q(<a href='#{url.downcase}' class='oy-link #{css}'>#{abbrev_title}</a>)
      rescue
        mk_link(url, css, "NIL")
      end


      # returns the default markup extesion as symbol
      def defext
        @defext ||= OY::Markup.default_extension.to_sym
      end


      processors << :process_page_link_tag
      # Makes a link for tag if there are no alternatives in the repos.
      #
      # If there are alternatives makes the link for the default markup, and
      # adds alternatives as superscript links after the base link.
      def process_page_link_tag(tag)
        parts = tag.split(' ')

        url, *descp = parts
        title = descp.join(" ")

        alternatives = Repos.alternatives(*url.split("/"))

        base_link, add_links = [], []

        extern_url = url =~ /^https?:/

        url = "/#{url}" if not url[0..0] == "/" and not extern_url
        title = url if title.empty?

        if extern_url
          return %Q{<a href="#{url}">#{title}</a>}
        end

        if not alternatives.empty?
          alternatives.each_pair do |ext, file|
            if ext == defext    # find page with default extension

              base_url =
                if alternatives.size > 1
                  # add extension for base_url unless given
                  url !~ /\.#{ext}$/ ? "#{url}.#{ext}" : url
                else url end

              base_link << [base_url, file]
            else
              add_links << ["#{url}.#{ext}", file]
            end
          end
        else
          # not existing page
          base_link << [url, nil]
        end

        # sort links by extension
        add_links = add_links.sort_by{|link, file| File.extname(file) }

        if base_link.empty?
          base_link << add_links.shift
        end

        title = title[1..-1] if title[0..0] == "/"

        base_link.map!{|url, _|  mk_link(url, (alternatives.empty? ? "o" : "x"), title) }
        add_links.map!{|url, _|  mk_link(url, 'alt', nil) }

        ret = base_link.join
        unless add_links.empty?
          ret << " <span class='alts'><sup>(%s)</sup></span>" % add_links.join(", ")
        end
        ret
      end

      #########################################################################
      #
      # Code
      #
      #########################################################################

      # Extract all code blocks into the codemap and replace with placeholders.
      #
      # data - The raw String data.
      #
      # Returns the placeholder'd String data.
      #
      # From Gollum: lib/gollum/markup.rb
      def extract_code!
        data = @data
        data.gsub!(/^``` ?([^\r\n]+)?\r?\n(.+?)\r?\n```\r?$/m) do
          id     = Digest::SHA1.hexdigest($2)
          cached = check_cache(:code, id)
          @codemap[id] = cached   ?
          { :output => cached } :
            { :lang => $1, :code => $2 }
          id
        end
        data
      end

      # Process all code from the codemap and replace the placeholders with the
      # final HTML.
      #
      # data - The String data (with placeholders).
      #
      # FIXME: Maybe add albino too?
      #
      # Returns the marked up String data.
      #
      # From Gollum: lib/gollum/markup.rb
      def process_code(data)
        @codemap.each do |id, spec|
          formatted = spec[:output] ||
            begin
              code = spec[:code]
              lang = spec[:lang]

              if code.lines.all? { |line| line =~ /\A\r?\n\Z/ || line =~ /^(  |\t)/ }
                code.gsub!(/^(  |\t)/m, '')
              end
              # formatted =
              #   begin
              #     lang && OY::Albino.colorize(code, lang)
              #   rescue ::Albino::ShellArgumentError, ::Albino::Process::TimeoutExceeded,
              #     ::Albino::Process::MaximumOutputExceeded
              #     p 23
              #   end
              formatted ||= "<pre><code class='#{lang}'>#{CGI.escapeHTML(code)}</code></pre>"
              update_cache(:code, id, formatted)
              formatted
            end
          data.gsub!(id, formatted)
        end
        data
      end

      # Hook for getting the formatted value of extracted tag data.
      #
      # type - Symbol value identifying what type of data is being extracted.
      # id   - String SHA1 hash of original extracted tag data.
      #
      # Returns the String cached formatted data, or nil.
      #
      # From Gollum: lib/gollum/markup.rb
      def check_cache(type, id)
      end

      # Hook for caching the formatted value of extracted tag data.
      #
      # type - Symbol value identifying what type of data is being extracted.
      # id   - String SHA1 hash of original extracted tag data.
      # data - The String formatted value to be cached.
      #
      # Returns nothing.
      #
      # From Gollum: lib/gollum/markup.rb
      def update_cache(type, id, data)
      end

      def to_html
        ret = ''
        extract_tags!
        extract_code!
        ret = process_tags(data)
        ret = process_code(data)
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
