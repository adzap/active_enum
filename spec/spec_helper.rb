$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'spec'))

require 'rubygems'
require 'spec/autorun'

require 'active_record'
require 'active_enum'

RAILS_ROOT = File.dirname(__FILE__)

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection({:adapter => 'sqlite3', :database => ':memory:'})

require 'schema'

class Person < ActiveRecord::Base; end

module SpecHelper

end

Spec::Runner.configure do |config|
  config.include SpecHelper
end
