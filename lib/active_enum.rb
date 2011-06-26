require 'active_enum/base'
require 'active_enum/extensions'
require 'active_enum/acts_as_enum' if defined?(ActiveRecord)
require 'active_enum/storage/abstract_store'

module ActiveEnum
  autoload :VERSION, 'active_enum/version'

  mattr_accessor :enum_classes
  @@enum_classes = []

  mattr_accessor :use_name_as_value
  @@use_name_as_value = false

  mattr_accessor :storage
  @@storage = :memory

  mattr_accessor :storage_options
  @@storage_options = {}

  def storage=(*args)
    @@storage_options = args.extract_options!
    @@storage = args.first
  end

  mattr_accessor :extend_classes
  @@extend_classes = [ defined?(ActiveRecord) && ActiveRecord::Base ].compact

  def self.extend_classes=(klasses)
    @@extend_classes = klasses
    klasses.each {|klass| klass.send(:include, ActiveEnum::Extensions) }
  end

  # Setup method for plugin configuration
  def self.setup
    yield self
  end

  class EnumDefinitions
    def enum(name, &block)
      class_name = name.to_s.camelize
      eval("class #{class_name} < ActiveEnum::Base; end", TOPLEVEL_BINDING)
      new_enum = Module.const_get(class_name)
      new_enum.class_eval(&block)
    end
  end

  # Define enums in bulk
  def self.define(&block)
    raise "Define requires block" unless block_given?
    EnumDefinitions.new.instance_eval(&block)
  end

  def self.storage_class
    @@storage_class ||= "ActiveEnum::Storage::#{storage.to_s.classify}Store".constantize
  end

end
