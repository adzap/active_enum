require File.join(File.dirname(__FILE__), 'formtastic2')

module FormtasticBootstrap
  module Inputs
    class EnumInput < FormtasticBootstrap::Inputs::SelectInput

      def raw_collection
        @raw_collection ||= begin
          raise "Attribute '#{@method}' has no enum class" unless enum = @object.class.active_enum_for(@method)
          enum.to_select
        end
      end

    end
  end
end