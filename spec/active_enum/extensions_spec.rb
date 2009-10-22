require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class Sex < ActiveEnum::Base
  value :id => 1, :name => 'Male'
  value :id => 2, :name => 'Female'
end

describe ActiveEnum::Extensions do
  before do
    person_class = define_model do
      enumerate :sex, :with => Sex
    end
    @person = person_class.new(:sex =>1) 
  end

  it 'should add class :enumerate method to ActiveRecord' do
    define_model.should respond_to(:enumerate)
  end

  it 'should allow implicit enumeration class from attribute name' do
    person_class = define_model do
      enumerate :sex
    end
    person_class.new.sex.enum.should == Sex
  end

  it 'should raise error if implicit enumeration class cannot be found' do
    lambda do
      define_model { enumerate :first_name }
    end.should raise_error(ActiveEnum::EnumNotFound)
  end

  describe "attribute with value" do
    it 'should return enum id for value' do
      sex = @person.sex
      sex.id.should == 1
    end

    it 'should return enum name for value' do
      sex = @person.sex
      sex.name.should == 'Male'
    end

    it 'should return enum class for attribute' do
      sex = @person.sex
      sex.enum.should == Sex
    end
  end

  describe "nil attribute value" do
    before do
      @person.sex = nil
    end

    it 'should return nil enum id' do
      sex = @person.sex
      sex.id.should be_nil
    end

    it 'should return nil enum name' do
      sex = @person.sex
      sex.name.should be_nil
    end

    it 'should return enum class for attribute' do
      sex = @person.sex
      sex.enum.should == Sex
    end
  end

  describe "attribute with undefined value" do
    before do
      @person.sex = -1
    end

    it 'should return nil enum id' do
      sex = @person.sex
      sex.id.should be_nil
    end

    it 'should return nil enum name' do
      sex = @person.sex
      sex.name.should be_nil
    end

    it 'should return enum class for attribute' do
      sex = @person.sex
      sex.enum.should == Sex
    end
  end

  describe "assigning enum name symbol to attribute" do

    it 'should store id value when valid enum name' do
      @person.sex = :female
      @person.sex.should == 2
    end

    it 'should store nil value when invalid enum name' do
      @person.sex = :invalid
      @person.sex.should == nil
    end

  end

  describe "use enum name as attribute value" do
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

  def define_model(&block)
    Class.new(Person, &block)
  end

end
