require "spec_helper"

describe ActiveEnum::ActsAsEnum do
  class Person < ActiveRecord::Base
    acts_as_enum :name_column => 'first_name'
  end

  class TestPerson < ActiveRecord::Base
    def self.extended_modules
      class << self
        self.included_modules
      end
    end
  end

  class SortedPerson < ActiveRecord::Base
    acts_as_enum :name_column => 'first_name', :order => :desc
  end

  before(:all) do
    Person.create!(:first_name => 'Dave', :last_name => 'Smith')
    Person.create!(:first_name => 'John', :last_name => 'Doe')
    SortedPerson.create!(:first_name => 'Dave', :last_name => 'Smith')
    SortedPerson.create!(:first_name => 'John', :last_name => 'Doe')
  end

  it "should mixin enum class methods only when act_as_enum defined" do
    expect(TestPerson.extended_modules).not_to include(ActiveEnum::ActsAsEnum::ClassMethods)
    TestPerson.acts_as_enum
    expect(TestPerson.extended_modules).to include(ActiveEnum::ActsAsEnum::ClassMethods)
  end

  context "#[]" do
    it "should return name column value when passing id to [] method" do
      expect(Person[1]).to eq('Dave')
    end

    it "should return id column value when passing string name to [] method" do
      expect(Person['Dave']).to eq(1)
      expect(Person['dave']).to eq(1)
    end

    it "should return id column value when passing symbol name to [] method" do
      expect(Person[:dave]).to eq(1)
    end
  end

  context '#to_select' do
    it "should return array for select helpers" do
      expect(Person.to_select).to eq([['Dave', 1], ['John', 2]])
    end

    it "should return sorted array from order value for select helpers when an order is specified" do
      expect(SortedPerson.to_select).to eq([['John', 2], ['Dave', 1]])
    end
  end

  context '#meta' do
    it "should return record attributes hash without id and name columns" do
      expect(Person.meta(1)).to eq(Person.find(1).attributes.except('id', 'first_name'))
    end
  end

  context '#include?' do
    it "should return true if value is integer and model has id" do
      expect(Person.exists?(id: 1)).to eq(true)
      expect(Person.include?(1)).to eq(true)
    end

    it "should return false if value is integer and model does not have id" do
      expect(Person.exists?(id: 100)).to eq(false)
      expect(Person.include?(100)).to eq(false)
    end

    it "should return super if value is a module" do
      expect(Person.include?(ActiveRecord::Attributes)).to eq(true)

      expect(Person.include?(Module.new)).to eq(false)
    end
  end
end
