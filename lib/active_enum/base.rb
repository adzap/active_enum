module ActiveEnum
  class DuplicateValue < StandardError; end
  class InvalidValue < StandardError; end

  class Base

    class << self

      def inherited(subclass)
        ActiveEnum.enum_classes << subclass
      end

      # :name => 'Foo', implicit ID
      # :id => 1, :name => 'Foo'
      # 1 => 'Foo'
      #
      def value(enum_value)
        @values ||= []

        id, name = id_and_name(enum_value)
        check_duplicate(id, name)

        @values << [id, name]
				sort_values! unless @order == :as_defined
      end

      # order enum values using :asc or :desc
      #
			def order(order)
				@order = order
			end

      def all
        @values || []
      end

      def ids
        @values.map {|v| v[0] }
      end

      def names
        @values.map {|v| v[1] }
      end

      def to_select
				@values.map {|v| [v[1], v[0]] }
      end

      def [](index)
        if index.is_a?(Fixnum)
          row = lookup_by_id(index)
          row[1] if row
        else
          row = lookup_by_name(index)
          row[0] if row
        end
      end

      private

      def lookup_by_id(index)
        @values.assoc(index)
      end

      def lookup_by_name(index)
        @values.rassoc(index.to_s) || @values.rassoc(index.to_s.titleize)
      end

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
        (ids.max || 0) + 1
      end

      def check_duplicate(id, name)
        if lookup_by_id(id)
          raise ActiveEnum::DuplicateValue, "The id #{id} is already defined for #{self} enum."
        elsif lookup_by_name(name)
          raise ActiveEnum::DuplicateValue, "The name #{name} is already defined for #{self} enum."
        end
      end

			def sort_values!
				case (@order || :asc)
				when :asc
					@values.sort! {|a,b| a[0] <=> b[0] }
				when :desc
					@values.sort! {|a,b| b[0] <=> a[0] }
				end
			end

    end

  end
end
