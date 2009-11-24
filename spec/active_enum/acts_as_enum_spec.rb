require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class Person < ActiveRecord::Base
  acts_as_enum :name_column => 'first_name'
end

describe ActiveEnum::ActsAsEnum do
  before(:all) do
    Person.create!(:first_name => 'Dave', :last_name => 'Smith')
    Person.create!(:first_name => 'John', :last_name => 'Doe')
  end

  it 'return name column value when passing id to [] method' do
    Person[1].should == 'Dave'
  end

  it 'return id column value when passing string name to [] method' do
    Person['Dave'].should == 1
    Person['dave'].should == 1
  end

  it 'return id column value when passing symbol name to [] method' do
    Person[:dave].should == 1
  end

  it 'should return array for select helpers from to_select' do
    Person.to_select.should == [['Dave', 1], ['John', 2]]
  end

  it 'should return sorted array from order value for select helpers from to_select' do
    Person.class_eval do
      acts_as_enum :name_column => 'first_name', :order => :desc
    end
    Person.to_select.should == [['John', 2], ['Dave', 1]] 
  end
end
