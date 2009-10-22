module ActiveEnum
  class Base

    class << self
      
      # :id => 1, :title => 'Foo'
      # :title => 'Foo'
      #
      def value(enum_value={})
        @values ||= [] 
        unless enum_value[:id]
          enum_value[:id] = max_id + 1 
        end
        @values << [enum_value[:id], enum_value[:name]]
        @values.sort! {|a,b| a[0] <=> b[0] }
      end

      def all
        @values || []
      end

      def find_by_id(index)
        @values.assoc(index)
      end

      def find_by_name(index)
        case index
        when String
          @values.rassoc(index)
        when Symbol
          @values.rassoc(index.to_s) || @values.rassoc(index.to_s.titleize)
        end
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
          row = find_by_id(index)
          row[1] if row
        else
          row = find_by_name(index)
          row[0] if row
        end
      end

      private
      
      def max_id
        ids.max || 0
      end

    end

  end
end
