require 'i18n'

module ActiveEnum
  module Storage
    class I18nStore < MemoryStore
      def initialize(enum_class, order, options={})
        super
        @scope = [ :active_enum ] + enum_class.name.split("::").map { |nesting| nesting.underscore.to_sym }
      end

      def get_by_id(id)
        row = _values.assoc(id)
        [ id, translate(row[1]) ] if row
      end

      def get_by_name(name)
        row = _values.rassoc(name.to_s)
        [ row[0], translate(row[1]) ] if row
      end

      def values
        _values.map { |(id, name)| get_by_id(id) }
      end

      def check_duplicate(id, name)
        if _values.assoc(id) || _values.rassoc(name.to_s)
          raise ActiveEnum::DuplicateValue
        end
      end

      private

      def translate(key)
        I18n.translate key, :scope => @scope
      end

    end
  end
end
