require 'active_enum/base'
require 'active_enum/extensions'
require 'active_enum/storage/abstract_store'
require 'active_enum/version'
require 'active_enum/railtie' if defined?(Rails)

module ActiveEnum
  mattr_accessor :enum_classes
  @@enum_classes = []

  mattr_accessor :use_name_as_value
  @@use_name_as_value = false

  mattr_accessor :raise_on_not_found
  @@raise_on_not_found = false

  mattr_accessor :storage
  @@storage = :memory

  mattr_accessor :storage_options
  @@storage_options = {}

  def storage=(*args)
    @@storage_options = args.extract_options!
    @@storage = args.first
  end

  mattr_accessor :extend_classes
  @@extend_classes = []

  # Setup method for plugin configuration
  def self.setup
    yield config
    extend_classes!
  end

  def self.config
    self
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

  private

  def self.extend_classes!
    extend_classes.each {|klass| klass.send(:include, ActiveEnum::Extensions) }
  end

end
