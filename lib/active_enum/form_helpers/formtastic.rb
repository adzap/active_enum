module ActiveEnum
  module FormHelpers
    module Formtastic
      def self.included(base)
        base.alias_method_chain :default_input_type, :active_enum
      end

      def default_input_type_with_active_enum(method, options)
        return :enum if @object.class.enum_for(method)
        default_input_type_without_active_enum
      end

      def enum_input(method, options)
        raise "Attribute '#{method}' has no enum class" unless enum = @object.class.enum_for(method)
        select_input(method, options.merge(:collection => enum.to_select))
      end

    end
  end
end

Formtastic::SemanticFormBuilder.send :include, ActiveEnum::FormHelpers::Formtastic
