Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'

  s.name              = 'oy'
  s.version           = '0.0.1'
  s.date              = '2011-01-15'
  s.rubyforge_project = 'oy'

  s.summary     = "Git-powered wiki."
  s.description = "A simple, Git-powered wiki in favor of Gollum with ramaze frontend."

  s.authors  = ["Michael 'entropie' Trommer"]
  s.email    = 'mictro@gmail.com'
  s.homepage = 'http://github.com/mictro/oy'

  s.require_paths = %w[lib app]

  s.executables = ["oy.rb"]
  s.default_executable = 'oy.rb'

  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[]

  s.add_dependency('grit', "~> 2.3.0")
  s.add_dependency('nokogiri', "~> 1.4.4")
  s.add_dependency('RedCloth', "~> 4.2.3")
  s.add_dependency('ramaze')
  s.add_dependency('OptionParser', "~> 0.5.1")
  s.add_dependency('rspec')    

  # = MANIFEST =
  s.files = %w[
    Rakefile.rb
    app/config.ru
    app/controller/api.rb
    app/controller/css.rb
    app/controller/media.rb
    app/controller/oy.rb
    app/controller/special.rb
    app/controller/wiki.rb
    app/layout/layout.haml
    app/model/git.rb
    app/public/css/b-base.css
    app/public/css/b-reset.css
    app/public/css/squaregrid.css
    app/public/favicon.ico
    app/public/js/jquery-ui.js
    app/public/js/jquery.js
    app/public/js/modernizr-1.6.min.js
    app/public/js/oy.js
    app/start.rb
    app/view/_foot.haml
    app/view/_fork.html
    app/view/_head.haml
    app/view/compare.haml
    app/view/create.haml
    app/view/css/oy.sass
    app/view/edit.haml
    app/view/form.haml
    app/view/history.haml
    app/view/index.haml
    app/view/oy/special/_image.haml
    app/view/oy/special/_images.haml
    app/view/oy/special/all.haml
    app/view/oy/special/media.haml
    app/view/oy/special/upload.haml
    app/view/revert.haml
    bin/oy.rb
    docs/index.textile
    lib/oy.rb
    lib/oy/api.rb
    lib/oy/blob_entry.rb
    lib/oy/exceptions.rb
    lib/oy/git_access.rb
    lib/oy/markup.rb
    lib/oy/markup/compare.rb
    lib/oy/markup/global.rb
    lib/oy/markup/nokogiri.rb
    lib/oy/markup/redcloth.rb
    lib/oy/repos.rb
    lib/oy/wiki/media.rb
    lib/oy/wiki/physical.rb
    lib/oy/wiki/wikidir.rb
    lib/oy/wiki/wikilock.rb
    script/polis_import.rb
    spec/01_spec_oy.rb
    spec/05_spec_wiki.rb
    spec/05_spec_wiki_dir.rb
    spec/06_spec_media.rb
    spec/06_spec_wiki_ops.rb
    spec/07_spec_virtual.rb
    spec/07_spec_wiki_lock.rb
    spec/10_spec_markup.rb
    spec/20_spec_api.rb
    spec/mk_specwiki.rb
    spec/spec.rb
    spec/spec_data/ass.jpg
    spec/spec_data/banner.gif
    spec/spec_helper.rb
  ]
  # = MANIFEST =

  s.test_files = s.files.select { |path| path =~ /^spec\/.*_spec_.*\.rb/ }
end
