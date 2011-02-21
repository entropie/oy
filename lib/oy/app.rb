#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Config
  class << self

    attr_accessor :repos
    attr_accessor :adapter

    def server
      @server ||= {}
    end

    def repos
      @repos || File.expand_path(".")
    end

    def adapter
      @adapter || :webrick
    end

    def setup
      yield self
    end
  end
end

# Orignal idea by Ryan Grove <ryan@wonko.com>
# https://github.com/rgrove/thoth/blob/master/lib/thoth.rb
# Modified by me to fit my needs.
module OY::App
  include Innate::Traited

  HOME_DIR   = OY::Source unless const_defined?(:HOME_DIR)
  LIB_DIR    = File.join(HOME_DIR, 'lib')
  APP_DIR    = File.join(HOME_DIR, 'app')
  PUBLIC_DIR = 'public' unless const_defined?(:PUBLIC_DIR)
  VIEW_DIR   = 'view' unless const_defined?(:VIEW_DIR)

  trait(:traits_broken => true)
  trait[:adapter]    ||= nil
  trait[:daemon]     ||= nil
  trait[:ip]         ||= nil
  trait[:irb]        ||= false
  trait[:mode]       ||= :production
  trait[:port]       ||= nil
  trait[:repos]      ||= nil
  trait[:pidfile]    ||= File.join("/tmp/", "oy.pid")

  module Helper; end

  class << self

    def init_oy
      trait[:ip]      ||= Config.server['address']
      trait[:port]    ||= Config.server['port']
      trait[:repos]   ||= Config.repos
      trait[:adapter] ||= Config.adapter
      # If caching is disabled, replace the default cache store with a no-op
      # API.
      # if Config.server['enable_cache']
      #   # Cache templates once read to prevent unnecessary disk thrashing.
      #   Innate::View.options.read_cache = true

      #   if Config.server['memcache']['enabled']
      #     Ramaze::Cache::MemCache::OPTIONS[:servers] = Config.server['memcache']['servers']
      #     Ramaze::Cache.options.default = Ramaze::Cache::MemCache
      #   end
      # else
      #   require 'thoth/cache'
      #   Ramaze::Cache.options.default = Thoth::Cache::Noop
      # end

      # Create a cache for plugins to use.
      # Ramaze::Cache.add(:plugin)

      # Tell Innate where to find Thoth's helpers.
      # Innate::HelpersHelper.options.paths << LIB_DIR
      # Innate::HelpersHelper.options.namespaces << Thoth::Helper

      Ramaze::Log.info "Oy! home   : #{HOME_DIR}"
      Ramaze::Log.info "Oy! lib    : #{LIB_DIR}"
      Ramaze::Log.info "Oy! app    : #{APP_DIR}"
      Ramaze::Log.info "Oy! view   : #{VIEW_DIR}"
      Ramaze::Log.info "Oy! public : #{PUBLIC_DIR}"
      Ramaze::Log.info "Running in #{trait[:mode] == :production ? 'live' : 'dev'} mode"

      Ramaze.options.setup << self
    end

    # Restarts the running Oy! daemon (if any).
    def restart
      stop
      sleep(1)
      start
    end

    # Runs Oy!.
    def run
      init_oy
      begin
        Ramaze.start(
          :adapter => trait[:adapter],
          :host    => trait[:ip],
          :port    => trait[:port],
          :root    => APP_DIR
        )
      rescue LoadError => ex
        Ramaze::Log.error("Unable to start Ramaze due to LoadError: #{ex}")
        exit(1)
      end
    end

    # Initializes Ramaze.
    def setup
      Ramaze.options.merge!(
        :mode  => trait[:mode] == :production ? :live : :dev,
        :roots => [APP_DIR]
      )

      Ramaze.options.roots.unshift(OY.path)
      [:layout, :public, :view].each do |opt|
        if OY::Repos.exist?("_#{opt}")
          rpath = OY::Repos.expand_path("_"+opt.to_s)
          Ramaze::Log.info "Ramaze.options[:#{opt}s] << #{rpath}"
          Ramaze.options.get("#{opt}s".to_sym)[:value].unshift "_#{opt}"
        end
      end

      case trait[:mode]
      when :devel
        Ramaze.middleware!(:dev) do |m|
          m.use Rack::Lint
          m.use Rack::CommonLogger, Ramaze::Log
          m.use Rack::ShowExceptions
          m.use Rack::ShowStatus
          m.use Rack::RouteExceptions
          m.use Rack::ConditionalGet
          m.use Rack::ETag
          m.use Rack::Head
          m.use Ramaze::Reloader
          m.use OY::Minify if Config.server['enable_minify']
          m.run Ramaze::AppMap
        end
      when :production
        Ramaze.middleware!(:live) do |m|
          m.use Rack::CommonLogger, Ramaze::Log
          m.use Rack::RouteExceptions
          m.use Rack::ShowStatus
          m.use Rack::ConditionalGet
          m.use Rack::ETag
          m.use Rack::Head
          m.use OY::Minify if Config.server['enable_minify']
          m.run Ramaze::AppMap
        end

        # Ensure that exceptions result in an HTTP 500 response.
        Rack::RouteExceptions.route(Exception, '/error_500')

        # Log all errors to the error log file if one is configured.
        if Config.server['error_log'].empty?
          Ramaze::Log.loggers = []
        else
          log_dir = File.dirname(Config.server['error_log'])

          unless File.directory?(log_dir)
            FileUtils.mkdir_p(log_dir)
            File.chmod(0750, log_dir)
          end

          Ramaze::Log.loggers = [Logger.new(Config.server['error_log'])]
          Ramaze::Log.level = Logger::Severity::ERROR
        end
      end
    end

    # Starts Oy! as a daemon.
    def start
      if File.file?(trait[:pidfile])
        pid = File.read(trait[:pidfile], 20).strip
        abort("Oy! already running? (pid=#{pid})")
      end

      puts "Starting Oy!."

      fork do
        Process.setsid
        exit if fork

        File.open(trait[:pidfile], 'w') {|file| file << Process.pid}
        at_exit {FileUtils.rm(trait[:pidfile]) if File.exist?(trait[:pidfile])}

        Dir.chdir(HOME_DIR)
        File.umask(0000)

        STDIN.reopen('/dev/null')
        STDOUT.reopen('/dev/null', 'a')
        STDERR.reopen(STDOUT)

        run
      end
    end

    # Stops the running Oy! daemon (if any).
    def stop
      unless File.file?(trait[:pidfile])
        abort("Oy! not running? (check #{trait[:pidfile]}).")
      end

      puts "Stopping Oy!."

      pid = File.read(trait[:pidfile], 20).strip
      FileUtils.rm(trait[:pidfile]) if File.exist?(trait[:pidfile])
      pid && Process.kill('SIGKILL', pid.to_i)
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
