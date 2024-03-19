module ActiveEnum
  module ActsAsEnum

    module MacroMethods

      def acts_as_enum(options={})
        extend ClassMethods
        class_attribute :active_enum_options
        self.active_enum_options = options.reverse_merge(name_column: 'name')
        scope :enum_values, proc { select(Arel.sql("#{primary_key}, #{active_enum_options[:name_column]}")).
                                   where(active_enum_options[:conditions]).
                                   order(Arel.sql("#{primary_key} #{active_enum_options[:order]}")) }
      end

    end

    module ClassMethods

      def values
        enum_values.map { |v| [ v.id, v.send(active_enum_options[:name_column]) ] }
      end

      def ids
        enum_values.map { |v| v.id }
      end

      def names
        enum_values.map { |v| v.send(active_enum_options[:name_column]) }
      end

      def to_select
        enum_values.map { |v| [v.send(active_enum_options[:name_column]), v.id] }
      end

      def [](index)
        get(index)
      end

      def get(index, raise_on_not_found: ActiveEnum.raise_on_not_found)
        row = get_value(index, raise_on_not_found)
        return if row.nil?
        index.is_a?(Integer) ? row.send(active_enum_options[:name_column]) : row.id
      end

      # Access any meta data defined for a given id or name. Returns a hash.
      def meta(index, raise_on_not_found: ActiveEnum.raise_on_not_found)
        row = lookup_relation(index).unscope(:select).first
        raise(ActiveEnum::NotFound, "#{self} value for '#{index}' was not found") if raise_on_not_found
        row&.attributes.except(primary_key.to_s, active_enum_options[:name_column].to_s)
      end

      # Enables use as a delimiter in inclusion validation
      def include?(value)
        return super if value.is_a?(Module)

        !self[value].nil?
      end

      private

      def get_value(index, raise_on_not_found = ActiveEnum.raise_on_not_found)
        lookup_relation(index).first || begin
          raise(ActiveEnum::NotFound, "#{self} value for '#{index}' was not found") if raise_on_not_found
        end
      end

      def lookup_relation(index)
        if index.is_a?(Integer)
          enum_values.where(id: index)
        else
          enum_values.where("lower(#{active_enum_options[:name_column]}) = lower(?)", Arel.sql(index.to_s))
        end
      end
    end

  end
end

ActiveRecord::Base.extend ActiveEnum::ActsAsEnum::MacroMethods
