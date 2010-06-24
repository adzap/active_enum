module ActiveEnum
  module FormHelpers
    class SimpleForm < SimpleForm::Inputs::CollectionInput

      def initialize(builder)
        super
        raise "Attribute '#{attribute_name}' has no enum class" unless enum = object.class.enum_for(attribute_name)
        builder.options[:collection] = enum.to_select
      end
      
    end
  end
end

SimpleForm::FormBuilder.class_eval do
  map_type :enum, :to => ActiveEnum::FormHelpers::SimpleForm
  alias_method :collection_enum, :collection_select
end
