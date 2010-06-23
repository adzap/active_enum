require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'active_enum/storage/active_record_store'

class TestARStoreEnum < ActiveEnum::Base; end
class TestOtherAREnum < ActiveEnum::Base; end

describe ActiveEnum::Storage::ActiveRecordStore do
  attr_accessor :store

  before(:all) do
    @default_storage = ActiveEnum.storage
    ActiveEnum.storage = :memory
  end

  context '#set' do
    it 'should store values in array' do
      store.set 1, 'Name 1'
      store.values.should == [[1, 'Name 1']]
    end
  end

  context "#values" do
    it 'should return only values for enum' do
      alt_store.set 1, 'Other Name 1'
      store.set 1, 'Name 1'
      store.values.should == [[1, 'Name 1']]
    end
  end

  context "#get_by_id" do
    it 'should return the value for a given id' do
      store.set 1, 'Name 1'
      store.get_by_id(1).should == [1, 'Name 1']
    end

    it 'should return nil when id not found' do
      store.get_by_id(1).should be_nil
    end

    it 'should return value for correct enum' do
      alt_store.set 1, 'Other Name 1'
      store.set 1, 'Name 1'
      store.get_by_id(1).should == [1, 'Name 1']
    end
  end

  context "#get_by_name" do
    it 'should return the value for a given name' do
      store.set 1, 'Name 1'
      store.get_by_name('Name 1').should == [1, 'Name 1']
    end

    it 'should return the value with title-cased name for a given lowercase name' do
      store.set 1, 'Name 1'
      store.get_by_name('name 1').should == [1, 'Name 1']
    end

    it 'should return nil when name not found' do
      store.get_by_name('test name').should be_nil
    end
    
    it 'should return value for correct enum' do
      alt_store.set 1, 'Other Name 1'
      store.set 1, 'Name 1'
      store.get_by_name('Name 1').should == [1, 'Name 1']
    end
  end

  context "sort!" do
    it 'should sort values ascending when passed :asc' do
      @order = :asc
      store.set 2, 'Name 2'
      store.set 1, 'Name 1'
      store.values.should == [[1,'Name 1'], [2, 'Name 2']]
    end

    it 'should sort values descending when passed :desc' do
      @order = :desc
      store.set 1, 'Name 1'
      store.set 2, 'Name 2'
      store.values.should == [[2, 'Name 2'], [1,'Name 1']]
    end

    it 'should not sort values when passed :as_defined' do
      @order = :as_defined
      store.set 1, 'Name 1'
      store.set 3, 'Name 3'
      store.set 2, 'Name 2'
      store.values.should == [[1,'Name 1'], [3,'Name 3'], [2, 'Name 2']]
    end
  end

  after do
    ActiveEnum::Model.delete_all
  end

  after(:all) do
    ActiveEnum.storage = @default_storage
  end

  def store
    @store ||= ActiveEnum::Storage::ActiveRecordStore.new(TestARStoreEnum, @order)
  end

  def alt_store
    @alt_store ||= ActiveEnum::Storage::ActiveRecordStore.new(TestOtherAREnum, :asc)
  end
end
