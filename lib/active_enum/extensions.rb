module ActiveEnum
  class EnumNotFound < StandardError; end

  module Extensions

    # Some of this stolen and modified from Roxy gem by Ryan Daigle
    def setup_active_enum_proxy(name, enum)
      define_attribute_methods unless generated_methods?

      original_method = instance_method(name)

      new_method = "proxied_#{name}"
      alias_method new_method, "#{name}"
      
      if original_method.arity == 0
        define_method(name) do
          (@enum_proxy_for ||= {})[name] ||= ActiveEnum::Proxy.new(self, original_method, nil, enum)
        end
      else
        define_method(name) do |*args|
          ActiveEnum::Proxy.new(self, original_method, args, enum)
        end
      end      
    end

    def define_enum_write_method(name, enum)
      method_name = "#{name}=".to_sym
      original_method = "#{name}_without_enum=".to_sym
      alias_method original_method, method_name

      define_method(method_name) do |arg|
        if arg.is_a?(Symbol)
          value = enum[arg] 
          send(original_method, value)
        else
          send(original_method, arg)
        end
      end
    end

    def enumerate(method, options={})
      enum = options[:with]
      unless enum
        enum = method.to_s.classify.constantize
      end
      
      setup_active_enum_proxy(method, enum)
      define_enum_write_method(method, enum)
    rescue NameError => e
      raise e unless e.message =~ /uninitialized constant/
      raise ActiveEnum::EnumNotFound, "Enum class could not be found for attribute '#{method}' in class #{self}. Specify the enum class using the :with option."
    end

  end
end

ActiveRecord::Base.extend ActiveEnum::Extensions
