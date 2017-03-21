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
    expect(ActiveRecord::Base).to respond_to(:enumerate)
  end

  it 'should add class :active_enum_for method to ActiveRecord' do
    expect(ActiveRecord::Base).to respond_to(:active_enum_for)
  end

  it 'should allow multiple attributes to be enumerated with same enum' do
    Person.enumerate :attending, :staying, :with => Accepted

    expect(Person.active_enum_for(:attending)).to eq(Accepted)
    expect(Person.active_enum_for(:staying)).to eq(Accepted)
  end

  it 'should allow multiple attributes to be enumerated with different enums' do
    Person.enumerate :sex, :with => Sex
    Person.enumerate :attending, :with => Accepted

    expect(Person.active_enum_for(:sex)).to eq(Sex) 
    expect(Person.active_enum_for(:attending)).to eq(Accepted)
  end

  it 'should allow implicit enumeration class from attribute name' do
    Person.enumerate :sex

    expect(Person.active_enum_for(:sex)).to eq(Sex)
  end

  it 'should create enum namespaced enum class from block' do
    Person.enumerate :sex do
      value :id => 1, :name => 'Male'
    end
    expect(Person.active_enum_for(:sex)).to eq(::Person::Sex)
  end
  
  it 'should raise error if implicit enumeration class cannot be found' do
    expect {
      Person.enumerate :first_name
    }.to raise_error(ActiveEnum::EnumNotFound)
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
        expect(person.sex).to eq(1)
      end

      it 'should return enum id for value' do
        expect(person.sex(:id)).to eq(1)
      end

      it 'should return enum name for value' do
        expect(person.sex(:name)).to eq('Male')
      end

      it 'should return enum class for attribute' do
        expect(person.sex(:enum)).to eq(Sex)
      end
    end

    context "with nil value" do
      let(:person) { Person.new(:sex => nil) }

      it 'should return nil with no arg' do
        expect(person.sex).to be_nil
      end

      it 'should return nil enum id' do
        expect(person.sex(:id)).to be_nil
      end

      it 'should return nil enum name' do
        expect(person.sex(:name)).to be_nil
      end

      it 'should return enum class for attribute' do
        expect(person.sex(:enum)).to eq(Sex)
      end

      context "and raise_on_not_found" do
        with_config :raise_on_not_found, true

        it "should not raise error when attribute is nil" do
          expect { person.sex(:id) }.to_not raise_error
        end
      end
    end

    context "with undefined value" do
      let(:person) { Person.new(:sex => -1) }

      it 'should return value with no arg' do
        expect(person.sex).to eq(-1)
      end

      it 'should return nil enum id' do
        expect(person.sex(:id)).to be_nil
      end

      it 'should return nil enum name' do
        expect(person.sex(:name)).to be_nil
      end

      it 'should return enum class for attribute' do
        expect(person.sex(:enum)).to eq(Sex)
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
        expect(person.sex(:description)).to eq('Man')
      end

      it 'should return nil for missing meta value' do
        expect(person.sex(:nonexistent)).to be_nil
      end

      it 'should return nil for missing index' do
        person.sex = nil
        expect(person.sex(:description)).to be_nil
      end
    end

    context "question method" do
      it 'should return normal value without arg' do
        expect(person.sex?).to be_truthy
        person.sex = nil
        expect(person.sex?).to be_falsey
      end

      it 'should return true if string name matches for id value' do
        expect(person.sex?("Male")).to be_truthy
      end

      it 'should return true if symbol name matches for id value' do
        expect(person.sex?(:male)).to be_truthy
        expect(person.sex?(:Male)).to be_truthy
      end

      it 'should return false if name does not match for id value' do
        expect(person.sex?("Female")).to be_falsey
        expect(person.sex?(:female)).to be_falsey
        expect(person.sex?(:Female)).to be_falsey
      end
    end

    context "with value as enum name symbol" do

      it 'should store id value when valid enum name' do
        person.sex = :female
        expect(person.sex).to eq(2)
      end

      it 'should store nil value when invalid enum name' do
        person.sex = :invalid
        expect(person.sex).to eq(nil)
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
        expect(person.sex).to eq('Male')
      end

      it 'should return true for boolean match' do
        expect(person.sex?(:male)).to be_truthy
      end

      after(:all) { ActiveEnum.use_name_as_value = false }
    end

  end
  
  context "with specified storage" do
    let(:person) { Person.new(:sex => 1) }

    before do
      @default_locale = I18n.locale
      I18n.backend.store_translations :en, :active_enum => { :person => { :sex => { 'male' => 'Male', 'female' => 'Female' } } }
      I18n.locale = :en

      reset_class Person do
        enumerate :sex, storage: :i18n do
          value 1 => 'male'
          value 2 => 'female'
        end
      end
    end

    after do
      I18n.locale = @default_locale
    end

    it 'should load the specified storage class instance' do
      Person.active_enum_for(:sex).send(:store).should be_instance_of(ActiveEnum::Storage::I18nStore)
    end

    it 'should return text name value for attribute' do
      person.sex(:name).should == 'Male'
    end
  end
end
