require 'simple_form/version'

module ActiveEnum
  module FormHelpers
    module SimpleForm
      module BuilderExtension

        def find_custom_type(attribute_name)
          return :enum if object.class.active_enum_for(attribute_name) if object.class.respond_to?(:active_enum_for)
          super
        end

      end
    end
  end
end

class ActiveEnum::FormHelpers::SimpleForm::EnumInput < ::SimpleForm::Inputs::CollectionSelectInput
  def initialize(*args)
    super
    raise "Attribute '#{attribute_name}' has no enum class" unless enum = object.class.active_enum_for(attribute_name)
    input_options[:collection] = enum.to_select
  end
end

class ActiveEnum::FormHelpers::SimpleForm::GroupedEnumInput < ::SimpleForm::Inputs::GroupedCollectionSelectInput
  def initialize(*args)
    super
    raise "Attribute '#{attribute_name}' has no enum class" unless enum = object.class.active_enum_for(attribute_name)

    input_options[:collection] = enum.to_grouped_select(input_options[:group_by])
    input_options[:group_method] = :last
  end
end

SimpleForm::FormBuilder.class_eval do
  prepend ActiveEnum::FormHelpers::SimpleForm::BuilderExtension

  map_type :enum, to: ActiveEnum::FormHelpers::SimpleForm::EnumInput
  map_type :grouped_enum, to: ActiveEnum::FormHelpers::SimpleForm::GroupedEnumInput

  alias_method :collection_enum, :collection_select
end
