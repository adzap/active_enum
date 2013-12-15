require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'

desc "Run specs"
RSpec::Core::RakeTask.new(:spec)

desc "Generate code coverage"
RSpec::Core::RakeTask.new(:coverage) do |t|
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
end

begin
  require 'rdoc/task'

  desc 'Generate documentation for plugin.'
  Rake::RDocTask.new(:rdoc) do |rdoc|
    rdoc.rdoc_dir = 'rdoc'
    rdoc.title    = 'ActiveEnum'
    rdoc.options << '--line-numbers' << '--inline-source'
    rdoc.rdoc_files.include('README')
    rdoc.rdoc_files.include('lib/**/*.rb')
  end
rescue LoadError
  puts 'RDocTask is not supported on this platform.'
end

desc 'Default: run specs.'
task :default => :spec

task :all do
  sh "export FORMTASTIC=2.0 && bundle install && bundle exec rake"
  sh "export FORMTASTIC=1.2 && bundle install && bundle exec rake"
end
