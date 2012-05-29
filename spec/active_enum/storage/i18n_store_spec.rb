require "spec_helper"

describe 'ActiveEnum::Storage::I18nStore' do
  class TestI18nStoreEnum < ActiveEnum::Base; end
  
  let(:enum_class) { TestI18nStoreEnum }
  let(:enum_key) { enum_class.name.underscore }
  let(:store) { ActiveEnum::Storage::I18nStore.new(enum_class, @order) }

  before(:all) do
    @_default_store = ActiveEnum.storage
    ActiveEnum.storage = :i18n
  end

  after(:all) do
    ActiveEnum.storage = @_default_store
  end

  before do
    @default_locale = I18n.locale
  end

  after do
    I18n.locale = @default_locale
  end

  describe '#set' do
    it 'should store value of id and name' do
      store.set 1, 'test name'
      store.send(:_values).should == [[1, 'test name']]
    end

    it 'should store value of id, name and meta hash' do
      store.set 1, 'test name', :description => 'meta'
      store.send(:_values).should == [[1, 'test name', {:description => 'meta'}]]
    end

    it 'should raise error if duplicate id' do
      expect {
        store.set 1, 'Name 1'
        store.set 1, 'Other Name'
      }.should raise_error(ActiveEnum::DuplicateValue)
    end

    it 'should raise error if duplicate name' do
      expect {
        store.set 1, 'Name 1'
        store.set 2, 'Name 1'
      }.should raise_error(ActiveEnum::DuplicateValue)
    end

    it 'should raise error if duplicate name matches title-case name' do
      expect {
        store.set 1, 'Name 1'
        store.set 1, 'name 1'
      }.should raise_error(ActiveEnum::DuplicateValue)
    end
  end

  describe "#values" do
    before do
      I18n.backend.store_translations :en, :active_enum => { enum_key => { :thanks => 'Thanks' } }
      I18n.backend.store_translations :fr, :active_enum => { enum_key => { :thanks => 'Merce' } }
    end

    it 'should return array of stored values for current locale' do
      store.set 1, 'thanks'

      I18n.locale = :en
      store.values.should == [ [1, 'Thanks'] ]

      I18n.locale = :fr
      store.values.should == [ [1, 'Merce'] ]
    end
  end

  describe "#get_by_id" do
    before do
      I18n.backend.store_translations :en, :active_enum => { enum_key => { 'test' => 'Testing' } }
    end

    it 'should return the value for a given id' do
      I18n.locale = :en

      store.set 1, 'test'
      store.get_by_id(1).should == [1, 'Testing']
    end

    it 'should return nil when id not found' do
      store.get_by_id(1).should be_nil
    end
  end

  describe "#get_by_name" do
    before do
      I18n.backend.store_translations :en, :active_enum => { enum_key => { 'test' => 'Testing' } }
    end

    it 'should return the value for a given name' do
      store.set 1, 'test'
      store.get_by_name('test').should == [1, 'Testing']
    end

    it 'should return nil when name not found' do
      store.get_by_name('test').should be_nil
    end
  end

  describe "#sort!" do
    before do
      I18n.backend.store_translations :en, :active_enum => { enum_key => { 
        'name1' => 'Name 1',
        'name2' => 'Name 2',
        'name3' => 'Name 3',
      } }
    end

    it 'should sort values ascending when passed :asc' do
      store = ActiveEnum::Storage::I18nStore.new(enum_class, :asc)

      store.set 2, 'name2'
      store.set 1, 'name1'
      store.values.should == [[1,'Name 1'], [2, 'Name 2']]
    end

    it 'should sort values descending when passed :desc' do
      store = ActiveEnum::Storage::I18nStore.new(enum_class, :desc)

      store.set 1, 'name1'
      store.set 2, 'name2'
      store.values.should == [[2, 'Name 2'], [1,'Name 1']]
    end

    it 'should not sort values when passed :natural' do
      store = ActiveEnum::Storage::I18nStore.new(enum_class, :natural)

      store.set 1, 'name1'
      store.set 3, 'name3'
      store.set 2, 'name2'
      store.values.should == [[1,'Name 1'], [3,'Name 3'], [2, 'Name 2']]
    end
  end

end
