require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ActiveEnum::ActsAsEnum do
  before(:all) do
    @person = Person.create!(:first_name => 'Dave', :last_name => 'Smith')
  end

  it 'should add acts_as_enum method to AR::Base' do
    Person.should respond_to(:acts_as_enum)
  end

  it 'return name column value when passing id to [] method' do
    class Person < ActiveRecord::Base
      acts_as_enum :name_column => 'first_name'
    end
    Person[@person.id].should == @person.first_name
  end

  it 'return id column value when passing name to [] method' do
    class Person < ActiveRecord::Base
      acts_as_enum :name_column => 'first_name'
    end
    Person[@person.first_name].should == @person.id
  end

  it 'should return array for select helpers from to_select' do
    class Person < ActiveRecord::Base
      acts_as_enum :name_column => 'first_name'
    end
    Person.to_select.should == [[@person.first_name, @person.id]]
  end
end
