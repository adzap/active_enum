module ActiveEnum
  module Storage
    class MemoryStore < AbstractStore
      attr_accessor :symbol_ids

      def set(id, name, meta=nil)
        raise ActiveEnum::InvalidId, 'Id cannot be string.' if id.is_a? String
        raise ActiveEnum::InvalidId, 'Id types cannot be mixed.' unless symbol_ids.nil? or symbol_ids? == id.is_a?(Symbol)

        self.symbol_ids = id.is_a?(Symbol) if self.symbol_ids.nil?

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

      def check_duplicate(id, name)
        if get_by_id(id) || get_by_name(name)
          raise ActiveEnum::DuplicateValue
        end
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

      def symbol_ids?
        !!symbol_ids
      end
    end
  end
end
