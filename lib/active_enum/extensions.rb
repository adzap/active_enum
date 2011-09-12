module ActiveEnum
  class EnumNotFound < StandardError; end

  module Extensions
    extend ActiveSupport::Concern

    included do
      class_attribute :enumerated_attributes
    end

    module ClassMethods

      # Declare an attribute to be enumerated by an enum class
      #
      # Example:
      #   class Person < ActiveRecord::Base
      #     enumerate :sex, :with => Sex
      #     enumerate :sex # implies a Sex enum class exists
      #
      #     # Pass a block to create implicit enum class namespaced by model e.g. Person::Sex
      #     enumerate :sex do
      #       value :id => 1, :name => 'Male'
      #     end
      #
      #     # Multiple attributes with same enum
      #     enumerate :to, :from, :with => Sex
      #
      def enumerate(*attributes, &block)
        options = attributes.extract_options!
        self.enumerated_attributes ||= {}

        attributes_enum = {}
        attributes.each do |attribute|
          begin
            if block_given?
              enum = define_implicit_enum_class_for_attribute(attribute, block)
            else
              enum = options[:with] || attribute.to_s.camelize.constantize
            end

            attribute = attribute.to_sym
            attributes_enum[attribute] = enum

            define_active_enum_methods_for_attribute(attribute)
          rescue NameError => e
            raise e unless e.message =~ /uninitialized constant/
            raise ActiveEnum::EnumNotFound, "Enum class could not be found for attribute '#{attribute}' in class #{self}. Specify the enum class using the :with option."
          end
        end
        enumerated_attributes.merge!(attributes_enum)
      end

      def active_enum_for(attribute)
        self.enumerated_attributes ||= {}
        enumerated_attributes[attribute.to_sym]
      end

      def define_active_enum_methods_for_attribute(attribute)
        define_active_enum_read_method(attribute)
        define_active_enum_write_method(attribute)
        define_active_enum_question_method(attribute)
      end

      def define_implicit_enum_class_for_attribute(attribute, block)
        enum_class_name = "#{name}::#{attribute.to_s.camelize}"
        eval("class #{enum_class_name} < ActiveEnum::Base; end")
        enum = enum_class_name.constantize
        enum.class_eval &block
        enum
      end

      # Define read method to allow an argument for the enum component
      #
      # Examples:
      #   user.sex
      #   user.sex(:id)
      #   user.sex(:name)
      #   user.sex(:enum)
      #   user.sex(:meta_key)
      #
      def define_active_enum_read_method(attribute)
        class_eval <<-DEF
          def #{attribute}(arg=nil)
            value = super()
            return if value.nil? && arg.nil?

            enum  = self.class.active_enum_for(:#{attribute})
            case arg
            when :id
              value if enum[value]
            when :name
              enum[value]
            when :enum
              enum
            when Symbol
              (enum.meta(value) || {})[arg]
            else
              #{ActiveEnum.use_name_as_value ? 'enum[value]' : 'value' }
            end
          end
        DEF
      end

      # Define write method to also handle enum value
      #
      # Examples:
      #   user.sex = 1
      #   user.sex = :male
      #
      def define_active_enum_write_method(attribute)
        class_eval <<-DEF
          def #{attribute}=(arg)
            if arg.is_a?(Symbol)
              value = self.class.active_enum_for(:#{attribute})[arg]
              super(value)
            else
              super(arg)
            end
          end
        DEF
      end

      # Define question method to check enum value against attribute value
      #
      # Example:
      #   user.sex?(:male)
      #
      def define_active_enum_question_method(attribute)
        define_method("#{attribute}?") do |*arg|
          arg = arg.first
          if arg
            send(attribute) == self.class.active_enum_for(attribute)[arg]
          else
            super()
          end
        end
      end

    end

  end
end
