# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{active_enum}
  s.version = "0.6.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Adam Meehan"]
  s.autorequire = %q{active_enum}
  s.date = %q{2010-03-17}
  s.description = %q{Define enum classes in Rails and use them to enumerate ActiveRecord attributes}
  s.email = %q{adam.meehan@gmail.com}
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["MIT-LICENSE", "README.rdoc", "Rakefile", "lib/active_enum", "lib/active_enum/acts_as_enum.rb", "lib/active_enum/base.rb", "lib/active_enum/extensions.rb", "lib/active_enum/formtastic.rb", "lib/active_enum/version.rb", "lib/active_enum.rb", "spec/active_enum", "spec/active_enum/acts_as_enum_spec.rb", "spec/active_enum/base_spec.rb", "spec/active_enum/extensions_spec.rb", "spec/active_enum/formtastic_spec.rb", "spec/active_enum_spec.rb", "spec/schema.rb", "spec/spec_helper.rb"]
  s.homepage = %q{http://github.com/adzap/active_enum}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{active_enum}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Define enum classes in Rails and use them to enumerate ActiveRecord attributes}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
