module ActiveEnum
  class DuplicateValue < StandardError; end
  class InvalidValue < StandardError; end
  class NotFound < StandardError; end

  class Base
    class << self
      attr_reader :store

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
        store.set(*id_and_name_and_meta(enum_value))
      end

      # Specify order enum values are returned.
      # Allowed values are :asc, :desc or :natural
      #
      def order(order)
        raise "Invalid order '#{order}' in #{self}" unless order.in?([:asc, :desc, :as_defined, :natural])

        if order == :as_defined
          ActiveSupport::Deprecation.warn("You are using the order :as_defined which has been deprecated. Use :natural.")
          order = :natural
        end
        @order = order
      end

      # Array of arrays of stored values defined id, name, meta values hash
      def values
        store.values
      end
      alias_method :all, :values

      def each(&block)
        all.each(&block)
      end

      # Array of all enum id values
      def ids
        store.values.map { |v| v[0] }
      end

      # Array of all enum name values
      def names
        store.values.map { |v| v[1] }
      end

      # Return enum values in an array suitable to pass to a Rails form select helper.
      def to_select(value_transform: ActiveEnum.default_select_value_transform)
        store.values.map(&value_transform)
      end

      # Return enum values in a nested array suitable to pass to a Rails form grouped select helper.
      def to_grouped_select(group_by, group_transform: ActiveEnum.default_select_group_transform, value_transform: ActiveEnum.default_select_value_transform)
        store.values.group_by { |(_id, _name, meta)| (meta || {})[group_by] }.map { |group, collection|
          [ group_transform.call(group), collection.map { |(id, name, _meta)| [ name.html_safe, id ] } ]
        }
      end

      # Return a simple hash of key value pairs id => name for each value
      def to_h
        store.values.inject({}) { |hash, row|
          hash.merge(row[0] => row[1])
        }
      end

      # Return count of values defined
      def length
        store.values.length
      end
      alias_method :size, :length

      # Access id or name value. Pass an id number to retrieve the name or
      # a symbol or string to retrieve the matching id.
      def get(index, raise_on_not_found:  ActiveEnum.raise_on_not_found)
        row = get_value(index, raise_on_not_found)
        return if row.nil?
        index.is_a?(Integer) ? row[1] : row[0]
      end

      def [](index)
        get(index)
      end

      def include?(value)
        !get_value(value, false).nil?
      end

      # Access any meta data defined for a given id or name. Returns a hash.
      def meta(index, raise_on_not_found: ActiveEnum.raise_on_not_found)
        row = get_value(index, raise_on_not_found)
        row[2] || {} if row
      end

      private

      # Access value row array for a given id or name value.
      def get_value(index, raise_on_not_found = ActiveEnum.raise_on_not_found)
        if index.is_a?(Integer)
          store.get_by_id(index)
        else
          store.get_by_name(index)
        end || (raise_on_not_found ? raise(ActiveEnum::NotFound, "#{self} value for '#{index}' was not found") : nil)
      end

      def id_and_name_and_meta(hash)
        if hash.has_key?(:name)
          id   = hash.fetch(:id) { next_id }
          name = hash.fetch(:name).freeze
          meta = hash.except(:id, :name).freeze
          return id, name, (meta.empty? ? nil : meta)
        elsif hash.keys.first.is_a?(Integer)
          return *Array(hash).first.tap { |arr| arr[1].freeze }
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
