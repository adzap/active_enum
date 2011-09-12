require 'rspec'

require 'rails'
require 'active_record'
require 'action_controller'
require 'action_view'
require 'action_mailer'

require 'active_enum'
require 'active_enum/acts_as_enum'

module Config
  class Application < Rails::Application
    config.generators do |g|
      g.orm             :active_record
      g.test_framework  :rspec, :fixture => false
    end
  end
end

require 'rspec/rails'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection({:adapter => 'sqlite3', :database => ':memory:'})

require 'schema'

class Person < ActiveRecord::Base; end
class NoEnumPerson < ActiveRecord::Base
  set_table_name 'people'
end

class NotActiveRecord
  include ActiveModel::Validations
  attr_accessor :name
end

ActiveEnum.extend_classes = [ActiveRecord::Base]
ActiveEnum.extend_classes!

module SpecHelper
  def reset_class(klass, &block)
    name = klass.name.to_sym
    Object.send(:remove_const, name)
    eval "class #{klass}#{' < ' + klass.superclass.to_s if klass.superclass != Class}; end", TOPLEVEL_BINDING
    new_klass = Object.const_get(name)
    new_klass.class_eval &block if block_given?
    new_klass
  end
end

RSpec.configure do |config|
  config.include SpecHelper
end
