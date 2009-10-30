require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class Person < ActiveRecord::Base
  acts_as_enum :name_column => 'first_name'
end

describe ActiveEnum::ActsAsEnum do
  before(:all) do
    @person = Person.create!(:first_name => 'Dave', :last_name => 'Smith')
  end

  it 'return name column value when passing id to [] method' do
    Person[@person.id].should == @person.first_name
  end

  it 'return id column value when passing string name to [] method' do
    Person['Dave'].should == @person.id
    Person['dave'].should == @person.id
  end

  it 'return id column value when passing symbol name to [] method' do
    Person[:dave].should == @person.id
  end

  it 'should return array for select helpers from to_select' do
    Person.to_select.should == [[@person.first_name, @person.id]]
  end
end
