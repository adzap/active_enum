module ActiveEnum

  module ActsAsEnum

    def self.included(base)
      base.extend MacroMethods
    end

    module MacroMethods

      def acts_as_enum(options={})
        extend ClassMethods
        class_inheritable_accessor :active_enum_options
        self.active_enum_options = options.reverse_merge(:name_column => 'name')
        scope :enum_values, select("#{primary_key}, #{active_enum_options[:name_column]}").
                            where(active_enum_options[:conditions]).
                            order("#{primary_key} #{active_enum_options[:order]}")
      end

    end

    module ClassMethods

      def ids
        enum_values.map {|v| v.id }
      end

      def names
        enum_values.map {|v| v.send(active_enum_options[:name_column]) }
      end

      def to_select
        enum_values.map {|v| [v.send(active_enum_options[:name_column]), v.id] }
      end

      def [](index)
        if index.is_a?(Fixnum)
          v = lookup_by_id(index)
          v.send(active_enum_options[:name_column]) unless v.blank?
        else
          v = lookup_by_name(index)
          v.id unless v.blank?
        end
      end

      private

      def lookup_by_id(index)
        enum_values.find_by_id(index)
      end

      def lookup_by_name(index)
        enum_values.where("#{active_enum_options[:name_column]} like ?", index.to_s).first
      end

    end

  end
end

ActiveRecord::Base.send :include, ActiveEnum::ActsAsEnum
