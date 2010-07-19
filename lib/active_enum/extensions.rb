module ActiveEnum
  class EnumNotFound < StandardError; end

  module Extensions

    def self.included(base)
      base.extend ClassMethods
      base.class_inheritable_accessor :enumerated_attributes
      base.enumerated_attributes = {}
    end

    module ClassMethods

      # Declare an attribute to be enumerated by an enum class
      #
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
				attributes.each do |attribute|
					begin
						if block_given?
              enum_class_name = "#{self.name}::#{attribute.to_s.camelize}"
              eval("class #{enum_class_name} < ActiveEnum::Base; end")
						  enum = enum_class_name.constantize
              enum.class_eval &block
						else
							enum = options[:with] || attribute.to_s.classify.constantize
						end
						attribute = attribute.to_sym
						self.enumerated_attributes[attribute] = enum

						define_active_enum_read_method(attribute)
						define_active_enum_write_method(attribute)
						define_active_enum_question_method(attribute)
					rescue NameError => e
						raise e unless e.message =~ /uninitialized constant/
						raise ActiveEnum::EnumNotFound, "Enum class could not be found for attribute '#{attribute}' in class #{self}. Specify the enum class using the :with option."
					end
				end
      end

      def enum_for(attribute)
        self.enumerated_attributes[attribute.to_sym]
      end

      # Define read method to allow an argument for the enum component
      #
      #   user.sex
      #   user.sex(:id)
      #   user.sex(:name)
      #   user.sex(:enum)
      #   user.sex(:meta_key)
      #
      def define_active_enum_read_method(attribute)
        define_method("#{attribute}") do |*arg|
          arg   = arg.first
          value = super()
          enum  = self.class.enum_for(attribute)

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
            ActiveEnum.use_name_as_value ? enum[value] : value
          end
        end
      end

      # Define write method to also handle enum value
      #
      #   user.sex = 1
      #   user.sex = :male
      #
      def define_active_enum_write_method(attribute)
        define_method("#{attribute}=") do |arg|
          enum = self.class.enum_for(attribute)
          if arg.is_a?(Symbol)
            value = enum[arg]
            super(value)
          else
            super(arg)
          end
        end
      end

      # Define question method to check enum value against attribute value
      #
      #   user.sex?(:male)
      #
      def define_active_enum_question_method(attribute)
        define_method("#{attribute}?") do |*arg|
          arg = arg.first
          if arg
            send(attribute) == self.class.enum_for(attribute)[arg]
          else
            super
          end
        end
      end

    end

  end
end

ActiveRecord::Base.send :include, ActiveEnum::Extensions
