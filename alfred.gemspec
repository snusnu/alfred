# Generated by jeweler
# DO NOT EDIT THIS FILE
# Instead, edit Jeweler::Tasks in Rakefile, and run `rake gemspec`
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{alfred}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["snusnu"]
  s.date = %q{2009-08-07}
  s.description = %q{Alfred is a friendly IRC butler that will manage interesting stuff on a dedicated website}
  s.email = %q{gamsnjaga@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "TODO",
     "VERSION",
     "alfred.gemspec",
     "lib/alfred/alfred.rb",
     "lib/alfred/config.rb",
     "lib/alfred/config.yml",
     "lib/alfred/models.rb",
     "lib/alfred/models/person.rb",
     "lib/alfred/models/post.rb",
     "lib/alfred/models/post_tag.rb",
     "lib/alfred/models/tag.rb",
     "lib/alfred/service.rb",
     "lib/alfred/views/commands.erb",
     "lib/alfred/views/layout.erb",
     "lib/alfred/views/posts.erb",
     "lib/alfred/views/tags.erb",
     "spec/alfred_spec.rb",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/snusnu/alfred}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{Alfred is a friendly IRC butler}
  s.test_files = [
    "spec/alfred_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end
