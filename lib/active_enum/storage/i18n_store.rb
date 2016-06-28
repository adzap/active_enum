require 'i18n'

module ActiveEnum
  module Storage
    class I18nStore < MemoryStore
      def get_by_id(id)
        row = _values.assoc(id)
        [ id, translate(row[1]), row[2] ].compact if row
      end

      def get_by_name(name)
        row = _values.rassoc(name.to_s)
        [ row[0], translate(row[1]), row[2] ].compact if row
      end

      def values
        _values.map { |(id, name)| get_by_id(id) }
      end

      def i18n_scope
        @i18n_scope ||= [ :active_enum ] + @enum.name.split("::").map { |nesting| nesting.underscore.to_sym }
      end

      def translate(key)
        I18n.translate key, :scope => i18n_scope, :default => key
      end

    end
  end
end
