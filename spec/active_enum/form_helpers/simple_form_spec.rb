require "spec_helper"

require 'simple_form'
require 'active_enum/form_helpers/simple_form'

describe ActiveEnum::FormHelpers::SimpleForm, :type => :helper do
  include SimpleForm::ActionViewExtensions::FormHelper

  before do
    allow(controller).to receive(:action_name).and_return('new')
    reset_class Person do
      enumerate :sex do
        value :id => 1, :name => 'Male'
        value :id => 2, :name => 'Female'
      end
    end
  end

  it "should use enum input type for enumerated attribute" do
    output = simple_form_for(Person.new, :url => people_path) do |f|
      concat f.input(:sex)
    end
    expect(output).to have_selector('select#person_sex')
    expect(output).to have_xpath('//option[@value=1]', :text => 'Male')
    expect(output).to have_xpath('//option[@value=2]', :text => 'Female')
  end

  it "should use explicit :enum input type" do
    output = simple_form_for(Person.new, :url => people_path) do |f|
      concat f.input(:sex, :as => :enum)
    end
    expect(output).to have_selector('select#person_sex')
    expect(output).to have_xpath('//option[@value=1]', :text => 'Male')
    expect(output).to have_xpath('//option[@value=2]', :text => 'Female')
  end

  it "should not use enum input type if :as option indicates other type" do
    output = simple_form_for(Person.new, :url => people_path) do |f|
      concat f.input(:sex, :as => :string)
    end
    expect(output).to have_selector('input#person_sex')
  end

  it "should raise error if attribute for enum input is not enumerated" do
    expect {
      simple_form_for(Person.new, :url => people_path) do |f|
        f.input(:attending, :as => :enum)
      end
    }.to raise_error "Attribute 'attending' has no enum class"
  end

  it "should not use enum input type if class does not support ActiveEnum" do
    output = simple_form_for(NotActiveRecord.new, :as => :not_active_record, :url => people_path) do |f|
      concat f.input(:name)
    end
    expect(output).to have_selector('input#not_active_record_name')
  end

  it "should allow non-enum fields to use default input determination" do
    output = simple_form_for(Person.new, :url => people_path) do |f|
      concat f.input(:first_name)
    end
    expect(output).to have_selector('input#person_first_name')
  end

  it "should allow models without enumerated attributes to behave normally" do
    output = simple_form_for(NoEnumPerson.new, :url => people_path) do |f|
      concat f.input(:first_name)
    end
    expect(output).to have_selector('input#no_enum_person_first_name')
  end

  def people_path
    '/people'
  end
end
