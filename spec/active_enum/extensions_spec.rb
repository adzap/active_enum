require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class Sex < ActiveEnum::Base
  value :id => 1, :name => 'Male'
  value :id => 2, :name => 'Female'
end

class Accepted < ActiveEnum::Base
  value :id => 0, :name => 'No'
  value :id => 1, :name => 'Definitely'
  value :id => 2, :name => 'Maybe'
end

describe ActiveEnum::Extensions do

  it 'should add class :enumerate method to ActiveRecord' do
    ActiveRecord::Base.should respond_to(:enumerate)
  end

  it 'should add class :enum_for method to ActiveRecord' do
    ActiveRecord::Base.should respond_to(:enum_for)
  end

  it 'should allow multiple attributes to be enumerated with same enum' do
    Person.class_eval do
      enumerate :attending, :staying, :with => Accepted
    end
    Person.enum_for(:attending).should == Accepted
    Person.enum_for(:staying).should == Accepted
  end

  it 'should allow implicit enumeration class from attribute name' do
    Person.class_eval do
      enumerate :sex
    end
    Person.enum_for(:sex).should == Sex
  end

  it 'should create enum namespaced enum class from block' do
    Person.class_eval do
      enumerate :sex do
        value :id => 1, :name => 'Male'
      end
    end
    Person.enum_for(:sex).should == Person::Sex
  end

  it 'should raise error if implicit enumeration class cannot be found' do
    lambda do
      Person.class_eval { enumerate :first_name }
    end.should raise_error(ActiveEnum::EnumNotFound)
  end

  describe "attribute" do
    before(:all) do
      reset_class Person do
        enumerate :sex, :with => Sex
      end
    end

    before do
      @person = Person.new(:sex =>1)
    end

    describe "with value" do
      it 'should return value with no arg' do
        @person.sex.should == 1
      end

      it 'should return enum id for value' do
        @person.sex(:id).should == 1
      end

      it 'should return enum name for value' do
        @person.sex(:name).should == 'Male'
      end

      it 'should return enum class for attribute' do
        @person.sex(:enum).should == Sex
      end
    end

    describe "with nil value" do
      before do
        @person.sex = nil
      end

      it 'should return nil with no arg' do
        @person.sex.should be_nil
      end

      it 'should return nil enum id' do
        @person.sex(:id).should be_nil
      end

      it 'should return nil enum name' do
        @person.sex(:name).should be_nil
      end

      it 'should return enum class for attribute' do
        @person.sex(:enum).should == Sex
      end
    end

    describe "with undefined value" do
      before do
        @person.sex = -1
      end

      it 'should return value with no arg' do
        @person.sex.should == -1
      end

      it 'should return nil enum id' do
        @person.sex(:id).should be_nil
      end

      it 'should return nil enum name' do
        @person.sex(:name).should be_nil
      end

      it 'should return enum class for attribute' do
        @person.sex(:enum).should == Sex
      end
    end

    describe "question method" do
      before do
        @person.sex = 1
      end

      it 'should return normal value without arg' do
        @person.sex?.should be_true
        @person.sex = nil
        @person.sex?.should be_false
      end

      it 'should return true if string name matches for id value' do
        @person.sex?("Male").should be_true
      end

      it 'should return true if symbol name matches for id value' do
        @person.sex?(:male).should be_true
        @person.sex?(:Male).should be_true
      end

      it 'should return false if name does not match for id value' do
        @person.sex?("Female").should be_false
        @person.sex?(:female).should be_false
        @person.sex?(:Female).should be_false
      end
    end

    describe "with value as enum name symbol" do

      it 'should store id value when valid enum name' do
        @person.sex = :female
        @person.sex.should == 2
      end

      it 'should store nil value when invalid enum name' do
        @person.sex = :invalid
        @person.sex.should == nil
      end

    end

    describe "with value as enum name" do
      before(:all) do
        ActiveEnum.use_name_as_value = true
      end

      it 'should return text name value for attribute' do
        @person.sex.should == 'Male'
      end

      after(:all) do
        ActiveEnum.use_name_as_value = false
      end
    end

  end

end
