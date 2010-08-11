$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'spec'))

require 'rubygems'
require 'rspec/autorun'

require 'active_record'
require 'action_controller'
require 'action_view'
require 'action_mailer'

require 'active_enum'

RAILS_ROOT = File.dirname(__FILE__)

require 'rspec/rails'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection({:adapter => 'sqlite3', :database => ':memory:'})
ActiveRecord::Base.logger = Logger.new('/dev/null')

ActiveEnum.extend_classes = [ActiveRecord::Base]

require 'schema'

class Person < ActiveRecord::Base; end

class NotActiveRecord
  include ActiveModel::Validations
  attr_accessor :name
end

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
