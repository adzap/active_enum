require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'active_enum/storage/memory_store'

class TestMemoryStoreEnum < ActiveEnum::Base
end

describe ActiveEnum::Storage::MemoryStore do
  attr_accessor :store

  before(:all) do
    @default_storage = ActiveEnum.storage
    ActiveEnum.storage = :memory
  end

  context '#set' do
    it 'should store values in array' do
      store.set 1, 'test name'
      store.values.should == [[1, 'test name']]
    end

    it 'should raise error if duplicate id' do
      lambda {
        store.set 1, 'Name 1'
        store.set 1, 'Other Name'
      }.should raise_error(ActiveEnum::DuplicateValue)
    end

    it 'should raise error if duplicate name' do
      lambda {
        store.set 1, 'Name 1'
        store.set 2, 'Name 1'
      }.should raise_error(ActiveEnum::DuplicateValue)
    end

    it 'should raise error if duplicate name matches title-case name' do
      lambda {
        store.set 1, 'Name 1'
        store.set 2, 'name 1'
      }.should raise_error(ActiveEnum::DuplicateValue)
    end
  end

  context "#get_by_id" do
    it 'should return the value for a given id' do
      store.set 1, 'test name'
      store.get_by_id(1).should == [1, 'test name']
    end

    it 'should return nil when id not found' do
      store.get_by_id(1).should be_nil
    end
  end

  context "#get_by_name" do
    it 'should return the value for a given name' do
      store.set 1, 'test name'
      store.get_by_name('test name').should == [1, 'test name']
    end

    it 'should return the value with title-cased name for a given lowercase name' do
      store.set 1, 'Test Name'
      store.get_by_name('test name').should == [1, 'Test Name']
    end

    it 'should return nil when name not found' do
      store.get_by_name('test name').should be_nil
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

  after(:all) do
    ActiveEnum.storage = @default_storage
  end

  def store
    @store ||= ActiveEnum::Storage::MemoryStore.new(TestMemoryStoreEnum, @order)
  end
end
