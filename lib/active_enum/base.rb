module ActiveEnum
  class DuplicateValue < StandardError; end
  class InvalidValue < StandardError; end

  class Base

    class << self
      attr_accessor :store

      def inherited(subclass)
        ActiveEnum.enum_classes << subclass
      end

      # :id => 1, :name => 'Foo'
      # :name => 'Foo'
      # 1 => 'Foo'
      #
      def value(enum_value)
        id, name = id_and_name(enum_value)
        store.set id, name
      end

      # Order enum values. Allowed values are :asc, :desc or :as_defined
      #
			def order(order)
				@order = order
			end

      def all
        store.values
      end

      def ids
        store.values.map {|v| v[0] }
      end

      def names
        store.values.map {|v| v[1] }
      end

      def to_select
				store.values.map {|v| [v[1], v[0]] }
      end

      def [](index)
        if index.is_a?(Fixnum)
          row = store.get_by_id(index)
          row[1] if row
        else
          row = store.get_by_name(index)
          row[0] if row
        end
      end

      private

      def id_and_name(hash)
        if hash.has_key?(:id) || hash.has_key?(:name)
          return (hash[:id] || next_id), hash[:name]
        elsif hash.keys.first.is_a?(Fixnum)
          return *Array(hash).first
        else
          raise ActiveEnum::InvalidValue, "The value supplied, #{hash}, is not a valid format."
        end
      end

      def next_id
        ids.max.to_i + 1
      end

      def store
        @store ||= storage_class.new(self, @order || :asc)
      end

      def storage_class
        "ActiveEnum::Storage::#{ActiveEnum.storage.to_s.classify}Store".constantize
      end

    end

  end
end
