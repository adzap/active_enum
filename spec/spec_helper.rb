ENV["RAILS_ENV"] ||= 'test'

require 'logger'
require 'rails'
require 'active_record'
require 'action_controller/railtie'
require 'action_view'
require 'action_mailer'

require 'active_enum'
require 'active_enum/acts_as_enum'

module ActiveEnum
  class Application < Rails::Application
    config.generators do |g|
      g.orm             :active_record
      g.test_framework  :rspec, :fixture => false
    end
    config.active_support.deprecation = :notify
  end
end

I18n.enforce_available_locales = false
I18n.available_locales = ['en', 'ja']

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection({:adapter => "sqlite3", :database => ':memory:'})

require 'rspec/rails'
require 'support/schema'

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |f| require f }

class Person < ActiveRecord::Base; end
class NoEnumPerson < ActiveRecord::Base
  self.table_name = 'people'
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
  config.include ConfigHelper

  # rspec-rails 3 will no longer automatically infer an example group's spec type
  # from the file location. You can explicitly opt-in to the feature using this
  # config option.
  # To explicitly tag specs without using automatic inference, set the `:type`
  # metadata manually:
  #
  #     describe ThingsController, :type => :controller do
  #       # Equivalent to being in spec/controllers
  #     end
  config.infer_spec_type_from_file_location!
end
