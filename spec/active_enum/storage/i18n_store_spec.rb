require "spec_helper"

describe ActiveEnum::Storage::I18nStore do
  class TestI18nStoreEnum < ActiveEnum::Base; end
  
  let(:enum_class) { TestI18nStoreEnum }
  let(:enum_key) { enum_class.name.underscore }
  let(:store) { ActiveEnum::Storage::I18nStore.new(enum_class, :asc) }

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
      }.to raise_error(ActiveEnum::DuplicateValue)
    end

    it 'should raise error if duplicate name' do
      expect {
        store.set 1, 'Name 1'
        store.set 2, 'Name 1'
      }.to raise_error(ActiveEnum::DuplicateValue)
    end

    it 'should not raise error if duplicate name with alternate case matches' do
      expect {
        store.set 1, 'Name 1'
        store.set 2, 'name 1'
      }.not_to raise_error()
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
      I18n.backend.store_translations :ja, :active_enum => { }
      I18n.locale = :en
    end

    it 'should return the value for a given id' do
      store.set 1, 'test'
      store.get_by_id(1).should == [1, 'Testing']
    end

    it 'should return the value with meta for a given id' do
      store.set 1, 'test', :description => 'meta'
      store.get_by_id(1).should == [1, 'Testing', { :description => 'meta' }]
    end

    it 'should return nil when id not found' do
      store.get_by_id(1).should be_nil
    end

    it 'should return key when translation missing' do
      I18n.locale = :ja
      store.set 1, 'test'
      store.get_by_id(1).should == [1, 'test']
    end
  end

  describe "#get_by_name" do
    before do
      I18n.backend.store_translations :en, :active_enum => { enum_key => { 'test' => 'Testing' } }
      I18n.locale = :en
    end

    it 'should return the value for a given name' do
      store.set 1, 'test'
      store.get_by_name('test').should == [1, 'Testing']
    end

    it 'should return the value with meta for a given name' do
      store.set 1, 'test', :description => 'meta'
      store.get_by_name('test').should == [1, 'Testing', { :description => 'meta' }]
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
      store = described_class.new(enum_class, :asc)

      store.set 2, 'name2'
      store.set 1, 'name1'
      store.values.should == [[1,'Name 1'], [2, 'Name 2']]
    end

    it 'should sort values descending when passed :desc' do
      store = described_class.new(enum_class, :desc)

      store.set 1, 'name1'
      store.set 2, 'name2'
      store.values.should == [[2, 'Name 2'], [1,'Name 1']]
    end

    it 'should not sort values when passed :natural' do
      store = described_class.new(enum_class, :natural)

      store.set 1, 'name1'
      store.set 3, 'name3'
      store.set 2, 'name2'
      store.values.should == [[1,'Name 1'], [3,'Name 3'], [2, 'Name 2']]
    end
  end

  context "loaded from yaml locale" do
    before do
      I18n.load_path << File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'support', 'i18n.yml'))
      I18n.reload!
      I18n.locale = :en
    end

    context "for top level enum" do
      class TopLevelEnum < ActiveEnum::Base; end
      let(:enum_class) { TopLevelEnum }

      it 'should return array values from yaml' do
        store.set 1, 'things'
        store.get_by_name('things').should eq [1, 'Generic things']
      end

      it 'should not load locale entry unless defined in enum' do
        store.set 1, 'things'
        store.get_by_name('not_found').should be_nil
      end
    end

    context "for namespaced model enum" do
      module Namespaced; class ModelEnum < ActiveEnum::Base; end; end
      let(:enum_class) { Namespaced::ModelEnum }

      it 'should return array values from yaml' do
        store.set 1, 'things'
        store.get_by_name('things').should eq [1, 'Model things']
      end

      it 'should not load locale entry unless defined in enum' do
        store.set 1, 'things'
        store.get_by_name('not_found').should be_nil
      end
    end

  end

end
