module Formtastic
  module Inputs
    class EnumInput < Formtastic::Inputs::SelectInput

      def raw_collection
        @raw_collection ||= begin
          raise "Attribute '#{@method}' has no enum class" unless enum = @object.class.active_enum_for(@method)
          enum.to_select
        end
      end

    end
  end
end

module ActiveEnum
  module FormHelpers
    module Formtastic2

      def default_input_type(method, options)
        return :enum if @object.class.respond_to?(:active_enum_for) && @object.class.active_enum_for(method)
        super
      end

    end
  end
end

Formtastic::FormBuilder.send :include, ActiveEnum::FormHelpers::Formtastic2
