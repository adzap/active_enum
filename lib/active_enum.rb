require 'active_enum/base'
require 'active_enum/extensions'
require 'active_enum/acts_as_enum'
require 'active_enum/version'

module ActiveEnum
  mattr_accessor :enum_classes
  self.enum_classes = []

  mattr_accessor :use_name_as_value
  self.use_name_as_value = false

  class Configuration
    def enum(name, &block)
      class_name = name.to_s.classify
      class_def = <<-end_eval
        class #{class_name} < ActiveEnum::Base
        end
      end_eval
      eval(class_def, TOPLEVEL_BINDING)
      new_enum = Module.const_get(class_name)
      new_enum.class_eval(&block)
    end
  end

  def self.define(&block)
    raise "Define requires block" unless block_given?
    Configuration.new.instance_eval(&block)
  end

end
