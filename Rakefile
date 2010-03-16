require 'rubygems'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'rubygems/specification'
require 'spec/rake/spectask'
require 'lib/active_enum/version'

GEM_NAME = "active_enum"
GEM_VERSION = ActiveEnum::VERSION

spec = Gem::Specification.new do |s|
  s.name = GEM_NAME
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.rubyforge_project = "active_enum"
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc"]
  s.summary = "Define enum classes in Rails and use them to enumerate ActiveRecord attributes"
  s.description = s.summary
  s.author = "Adam Meehan"
  s.email = "adam.meehan@gmail.com"
  s.homepage = "http://github.com/adzap/active_enum"

  s.require_path = 'lib'
  s.autorequire = GEM_NAME
  s.files = %w(MIT-LICENSE README.rdoc Rakefile) + Dir.glob("{lib,spec}/**/*")
end

desc 'Default: run specs.'
task :default => :spec

spec_files = Rake::FileList["spec/**/*_spec.rb"]

desc "Run specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = spec_files
  t.spec_opts = ["-c"]
end

desc "Generate code coverage"
Spec::Rake::SpecTask.new(:coverage) do |t|
  t.spec_files = spec_files
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec,/var/lib/gems']
end

desc 'Generate documentation for plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'ActiveEnum'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "install the gem locally"
task :install => [:package] do
  sh %{gem install pkg/#{GEM_NAME}-#{GEM_VERSION}}
end

desc "create a gemspec file"
task :make_spec do
  File.open("#{GEM_NAME}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end
