module ActiveEnum
  module Formtastic

    def enum_input(method, options)
      raise "Attribute '#{method}' has no enum class" unless enum = @object.class.active_enum_for(method)
      select_input(method, options.merge(:collection => enum.to_select))
    end

  end
end

Formtastic::SemanticFormBuilder.send :include, ActiveEnum::Formtastic
