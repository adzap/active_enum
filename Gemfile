source 'http://rubygems.org'

gemspec

rails_version = ENV["RAILS_VERSION"] || "default"

rails = case rails_version
when "master"
  {github: "rails/rails"}
when "default"
  ">= 3.1.0"
else
  "~> #{rails_version}"
end

gem "rails", rails

platforms :jruby do
  gem 'jdbc-sqlite3', :require => false
  gem 'activerecord-jdbc-adapter'
  gem 'activerecord-jdbcsqlite3-adapter'
end

platforms :ruby do
  gem 'sqlite3'
end

gem 'rake'
gem 'ZenTest'
gem 'simple_form'
gem 'formtastic', "~> #{ENV['FORMTASTIC'] || '2.0'}"
gem 'ruby-debug', :platform => :ruby_18
gem 'debugger', :platform => :ruby_19
gem 'rspec', '~> 2.4'
gem 'rspec-rails', '~> 2.4'
gem 'webrat'
