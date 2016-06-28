module ActiveEnum
  module Storage
    autoload :MemoryStore, "active_enum/storage/memory_store"
    autoload :I18nStore, "active_enum/storage/i18n_store"

    class NotImplemented < StandardError; end

    class AbstractStore 
      def initialize(enum_class, order, options={})
        @enum, @order, @options = enum_class, order, options
      end

      def set(id, name, meta=nil)
        raise NotImplemented
      end

      def get_by_id(id)
        raise NotImplemented
      end

      def get_by_name(name)
        raise NotImplemented
      end

      def check_duplicate(id, name)
        if get_by_id(id) 
          raise ActiveEnum::DuplicateValue, "#{@enum}: Duplicate id #{id}"
        elsif get_by_name(name)
          raise ActiveEnum::DuplicateValue, "#{@enum}: Duplicate name '#{name}'"
        end
      end

      def values
        _values
      end

      private
      
      def _values
        raise NotImplemented
      end

    end
  end
end
