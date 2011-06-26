# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "active_enum/version"

Gem::Specification.new do |s|
  s.name        = "active_enum"
  s.version     = ActiveEnum::VERSION
  s.authors     = ["Adam Meehan"]
  s.summary     = %q{Define enum classes in Rails and use them to enumerate ActiveRecord attributes}
  s.description = %q{Define enum classes in Rails and use them to enumerate ActiveRecord attributes}
  s.email       = %q{adam.meehan@gmail.com}
  s.homepage    = %q{http://github.com/adzap/active_enum}

  s.require_paths    = ["lib"]
  s.files            = `git ls-files`.split("\n") - %w{ .gitignore .rspec Gemfile Gemfile.lock autotest/discover.rb }
  s.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.extra_rdoc_files = ["README.rdoc", "CHANGELOG", "MIT-LICENSE"]
end
