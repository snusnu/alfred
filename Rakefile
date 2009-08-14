require 'rubygems'
require 'pathname'
require 'rake'

ROOT = Pathname(__FILE__).dirname.expand_path

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|

    gem.name = "alfred"
    gem.summary = %Q{Alfred the friendly IRC butler}
    gem.description = %Q{Alfred the friendly IRC butler is an IRC bot that lets you post stuff to its website}
    gem.email = "gamsnjaga@gmail.com"
    gem.homepage = "http://github.com/snusnu/alfred"
    gem.authors = ["snusnu", "armitage", "michael"]

    gem.bindir = 'bin'
    gem.executables = ['bin/bot', 'bin/service']

    gem.add_dependency('json',                   '>= 1.1.3' )
    gem.add_dependency('isaac',                  '>= 0.2.5' )
    gem.add_dependency('rdiscount',              '>= 1.3.5' )
    gem.add_dependency('rest-client',            '>= 1.0.3' )
    gem.add_dependency('sinatra',                '>= 0.10.1')
    gem.add_dependency('dm-core',                '>= 0.10.0')
    gem.add_dependency('dm-types',               '>= 0.10.0')
    gem.add_dependency('dm-constraints',         '>= 0.10.0')
    gem.add_dependency('dm-validations',         '>= 0.10.0')
    gem.add_dependency('dm-timestamps',          '>= 0.10.0')
    gem.add_dependency('dm-is-self_referential', '>= 0.0.1' )

    gem.has_rdoc = false

  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "alfred #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Pathname.glob(ROOT.join('tasks/**/*.rb').to_s).each { |f| require f }
