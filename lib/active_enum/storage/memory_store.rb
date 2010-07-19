module ActiveEnum
  module Storage
    class MemoryStore < AbstractStore
      def set(id, name, meta=nil)
        check_duplicate id, name
        values << [id, name, meta].compact
        sort!
      end

      def get_by_id(id)
        values.assoc(id)
      end

      def get_by_name(name)
        values.rassoc(name.to_s) || values.rassoc(name.to_s.titleize)
      end

      def values
        @values ||= []
      end

      def check_duplicate(id, name)
        if get_by_id(id) || get_by_name(name)
          raise ActiveEnum::DuplicateValue
        end
      end

      def sort!
        return if @order == :as_defined

        case @order
        when :asc
          values.sort! {|a,b| a[0] <=> b[0] }
        when :desc
          values.sort! {|a,b| b[0] <=> a[0] }
        end
      end
    end
  end
end
