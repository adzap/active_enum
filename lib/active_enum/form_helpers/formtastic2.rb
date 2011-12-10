module Formtastic
  module Inputs
    class EnumInput < Formtastic::Inputs::SelectInput
      def raw_collection
        raise "Attribute '#{@method}' has no enum class" unless enum = @object.class.active_enum_for(@method)
        @raw_collection ||= enum.to_select
      end
    end
  end
end

module ActiveEnum
  module FormHelpers
    module Formtastic2
      def default_input_type_with_active_enum(method, options)
        return :enum if @object.class.respond_to?(:active_enum_for) && @object.class.active_enum_for(method)
        default_input_type_without_active_enum(method, options)
      end
    end
  end
end

Formtastic::Helpers::InputHelper.class_eval do
  include ActiveEnum::FormHelpers::Formtastic2
  alias_method_chain :default_input_type, :active_enum
end
