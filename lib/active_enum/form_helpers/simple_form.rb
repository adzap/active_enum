require 'simple_form/version'

module ActiveEnum
  module FormHelpers
    module SimpleForm
      module BuilderExtension

        def default_input_type_with_active_enum(*args, &block)
          return :enum if (args.last.is_a?(Hash) ? args.last[:as] : @options[:as]).nil? &&
                          object.class.respond_to?(:active_enum_for) &&
                          object.class.active_enum_for(args.first || @attribute_name)
          default_input_type_without_active_enum(*args, &block)
        end

      end

      module InputExtension

        def initialize(*args)
          super
          raise "Attribute '#{attribute_name}' has no enum class" unless enum = object.class.active_enum_for(attribute_name)
          if respond_to?(:input_options)
            input_options[:collection] = enum.to_select
          else
            @builder.options[:collection] = enum.to_select
          end
        end
        
      end
    end
  end
end

if SimpleForm::VERSION < '2.0.0'
  class ActiveEnum::FormHelpers::SimpleForm::EnumInput < ::SimpleForm::Inputs::CollectionInput
    include ActiveEnum::FormHelpers::SimpleForm::InputExtension
  end
else
  class ActiveEnum::FormHelpers::SimpleForm::EnumInput < ::SimpleForm::Inputs::CollectionSelectInput
    include ActiveEnum::FormHelpers::SimpleForm::InputExtension
  end
end

SimpleForm::FormBuilder.class_eval do
  include ActiveEnum::FormHelpers::SimpleForm::BuilderExtension

  map_type :enum, :to => ActiveEnum::FormHelpers::SimpleForm::EnumInput
  alias_method :collection_enum, :collection_select
  alias_method_chain :default_input_type, :active_enum
end
