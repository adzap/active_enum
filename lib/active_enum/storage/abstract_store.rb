module ActiveEnum
  module Storage
    class NotImplemented < StandardError; end

    class AbstractStore 
      def initialize(enum_class, order)
        @enum, @order = enum_class, order
      end

      def set(id, name)
        raise NotImplemented
      end

      def get_by_id(id)
        raise NotImplemented
      end

      def get_by_name(name)
        raise NotImplemented
      end

      def values
        raise NotImplemented
      end
    end
  end
end
