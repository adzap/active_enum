require "spec_helper"

describe ActiveEnum::Extensions do
  class Sex < ActiveEnum::Base
    value :id => 1, :name => 'Male'
    value :id => 2, :name => 'Female'
  end

  class Accepted < ActiveEnum::Base
    value :id => 0, :name => 'No'
    value :id => 1, :name => 'Definitely'
    value :id => 2, :name => 'Maybe'
  end

  it 'should add class :enumerate method to ActiveRecord' do
    ActiveRecord::Base.should respond_to(:enumerate)
  end

  it 'should add class :active_enum_for method to ActiveRecord' do
    ActiveRecord::Base.should respond_to(:active_enum_for)
  end

  it 'should allow multiple attributes to be enumerated with same enum' do
    Person.enumerate :attending, :staying, :with => Accepted

    Person.active_enum_for(:attending).should == Accepted
    Person.active_enum_for(:staying).should == Accepted
  end

  it 'should allow multiple attributes to be enumerated with different enums' do
    Person.enumerate :sex, :with => Sex
    Person.enumerate :attending, :with => Accepted

    Person.active_enum_for(:sex).should == Sex 
    Person.active_enum_for(:attending).should == Accepted
  end

  it 'should allow implicit enumeration class from attribute name' do
    Person.enumerate :sex

    Person.active_enum_for(:sex).should == Sex
  end

  it 'should create enum namespaced enum class from block' do
    Person.enumerate :sex do
      value :id => 1, :name => 'Male'
    end
    Person.active_enum_for(:sex).should == ::Person::Sex
  end

  it 'should raise error if implicit enumeration class cannot be found' do
    expect {
      Person.enumerate :first_name
    }.should raise_error(ActiveEnum::EnumNotFound)
  end

  context "attribute" do
    let(:person) { Person.new(:sex => 1) }

    before(:all) do
      reset_class Person do
        enumerate :sex, :with => Sex
      end
    end

    context "with value" do
      it 'should return value with no arg' do
        person.sex.should == 1
      end

      it 'should return enum id for value' do
        person.sex(:id).should == 1
      end

      it 'should return enum name for value' do
        person.sex(:name).should == 'Male'
      end

      it 'should return enum class for attribute' do
        person.sex(:enum).should == Sex
      end
    end

    context "with nil value" do
      let(:person) { Person.new(:sex => nil) }

      it 'should return nil with no arg' do
        person.sex.should be_nil
      end

      it 'should return nil enum id' do
        person.sex(:id).should be_nil
      end

      it 'should return nil enum name' do
        person.sex(:name).should be_nil
      end

      it 'should return enum class for attribute' do
        person.sex(:enum).should == Sex
      end
    end

    context "with undefined value" do
      let(:person) { Person.new(:sex => -1) }

      it 'should return value with no arg' do
        person.sex.should == -1
      end

      it 'should return nil enum id' do
        person.sex(:id).should be_nil
      end

      it 'should return nil enum name' do
        person.sex(:name).should be_nil
      end

      it 'should return enum class for attribute' do
        person.sex(:enum).should == Sex
      end
    end

    context "with meta data" do
      let(:person) { Person.new(:sex =>1) }

      before(:all) do
        reset_class Person do
          enumerate :sex do
            value :id => 1, :name => 'Male',   :description => 'Man'
            value :id => 2, :name => 'Female', :description => 'Woman'
          end
        end
      end

      it 'should return meta value for existing key' do
        person.sex(:description).should == 'Man'
      end

      it 'should return nil for missing meta value' do
        person.sex(:nonexistent).should be_nil
      end

      it 'should return nil for missing index' do
        person.sex = nil
        person.sex(:description).should be_nil
      end
    end

    context "question method" do
      it 'should return normal value without arg' do
        person.sex?.should be_true
        person.sex = nil
        person.sex?.should be_false
      end

      it 'should return true if string name matches for id value' do
        person.sex?("Male").should be_true
      end

      it 'should return true if symbol name matches for id value' do
        person.sex?(:male).should be_true
        person.sex?(:Male).should be_true
      end

      it 'should return false if name does not match for id value' do
        person.sex?("Female").should be_false
        person.sex?(:female).should be_false
        person.sex?(:Female).should be_false
      end
    end

    context "with value as enum name symbol" do

      it 'should store id value when valid enum name' do
        person.sex = :female
        person.sex.should == 2
      end

      it 'should store nil value when invalid enum name' do
        person.sex = :invalid
        person.sex.should == nil
      end

    end

    context "with value as enum name" do
      before(:all) { ActiveEnum.use_name_as_value = true }
      let(:person) { Person.new(:sex =>1) }

      before do 
        reset_class Person do
          enumerate :sex, :with => Sex
        end
      end 

      it 'should return text name value for attribute' do
        person.sex.should == 'Male'
      end

      it 'should return true for boolean match' do
        person.sex?(:male).should be_true
      end

      after(:all) { ActiveEnum.use_name_as_value = false }
    end

  end

end
