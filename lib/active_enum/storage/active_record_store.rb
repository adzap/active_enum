module ActiveEnum
  class Model < ActiveRecord::Base
    set_table_name 'enums'
  end

  module Storage
    class ActiveRecordStore < AbstractStore
      def set(id, name)
        ActiveEnum::Model.create!(:enum_id => id, :name => name , :enum_type => @enum.name)
      end

      def get_by_id(id)
        value = ActiveEnum::Model.find(:first, :conditions => {:enum_id => id, :enum_type => @enum.name})
        [value.enum_id, value.name] if value
      end

      def get_by_name(name)
        value = ActiveEnum::Model.find(:first, :conditions => "enum_type = '#{@enum.name}' and (name = '#{name}' or name = '#{name.to_s.titleize}')")
        [value.enum_id, value.name] if value
      end

      def values
        ActiveEnum::Model.all(:conditions => {:enum_type => @enum.name}, :order => order_by).map {|r| [r.enum_id, r.name] }
      end

      def order_by
        @order_by ||= case @order
        when :asc
          'enum_id ASC'
        when :desc
          'enum_id DESC'
        else
          'modified_at ASC'
        end
      end
    end
  end
end
