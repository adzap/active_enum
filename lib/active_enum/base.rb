module ActiveEnum
  class DuplicateValue < StandardError; end
  class InvalidValue < StandardError; end

  class Base

    class << self
      attr_accessor :store

      def inherited(subclass)
        ActiveEnum.enum_classes << subclass
      end

      # Define enum values.
      #
      # Examples:
      #   value :id => 1, :name => 'Foo'
      #   value :name => 'Foo' # implicit id, incrementing from 1.
      #   value 1 => 'Foo'
      #
      def value(enum_value)
        store.set *id_and_name_and_meta(enum_value)
      end

      # Specify order enum values are returned. 
      # Allowed values are :asc, :desc or :as_defined
      #
      def order(order)
        @order = order
      end

      def all
        store.values
      end

      # Array of all enum id values
      def ids
        store.values.map {|v| v[0] }
      end

      # Array of all enum name values
      def names
        store.values.map {|v| v[1] }
      end

      # Return enum values in an array suitable to pass to a Rails form select helper.
      def to_select
				store.values.map {|v| [v[1], v[0]] }
      end

      # Access id or name value. Pass an id number to retrieve the name or
      # a symbol or string to retrieve the matching id.
      def [](index)
        if index.is_a?(Fixnum)
          row = store.get_by_id(index)
          row[1] if row
        else
          row = store.get_by_name(index)
          row[0] if row
        end
      end

      # Access any meta data defined for a given id or name. Returns a hash.
      def meta(index)
        row = if index.is_a?(Fixnum)
          store.get_by_id(index)
        else
          store.get_by_name(index)
        end
        row[2] || {} if row
      end

      private

      def id_and_name_and_meta(hash)
        if hash.has_key?(:id) || hash.has_key?(:name)
          id   = hash.delete(:id) || next_id
          name = hash.delete(:name)
          meta = hash
          return id, name, (meta.blank? ? nil : meta)
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
        @store ||= ActiveEnum.storage_class.new(self, @order || :asc, ActiveEnum.storage_options)
      end

    end

  end
end
