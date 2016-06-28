module ActiveEnum
  module Storage
    class MemoryStore < AbstractStore

      def set(id, name, meta=nil)
        check_duplicate id, name
        _values << [id, name.to_s, meta].compact
        sort!
      end

      def get_by_id(id)
        _values.assoc(id)
      end

      def get_by_name(name)
        _values.rassoc(name.to_s) || _values.rassoc(name.to_s.titleize)
      end

      def sort!
        case @order
        when :asc
          _values.sort! { |a,b| a[0] <=> b[0] }
        when :desc
          _values.sort! { |a,b| b[0] <=> a[0] }
        end
      end

      def _values
        @_values ||= []
      end

    end
  end
end
