require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'formtastic'
require 'active_enum/form_helpers/formtastic'

describe ActiveEnum::FormHelpers::Formtastic, :type => :helper do
  include Formtastic::SemanticFormHelper

  before do
    reset_class Person do
      enumerate :sex do
        value :id => 1, :name => 'Male'
        value :id => 2, :name => 'Female'
      end
    end
  end

  it "should use enum input type for enumerated attribute" do
    output = semantic_form_for(Person.new, :url => people_path) do |f|
      concat f.input(:sex)
    end
    output.should have_selector('select#person_sex')
    output.should have_xpath('//option[@value=1]', :content => 'Male')
    output.should have_xpath('//option[@value=2]', :content => 'Female')
  end

  it "should use explicit :enum input type" do
    output = semantic_form_for(Person.new, :url => people_path) do |f|
      concat f.input(:sex, :as => :enum)
    end
    output.should have_selector('select#person_sex')
    output.should have_xpath('//option[@value=1]', :content => 'Male')
    output.should have_xpath('//option[@value=2]', :content => 'Female')
  end

  it "should not use enum input type if :as option indicates other type" do
    output = semantic_form_for(Person.new, :url => people_path) do |f|
      concat f.input(:sex, :as => :string)
    end
    output.should have_selector('input#person_sex')
  end

  it "should raise error if attribute for enum input is not enumerated" do
    expect {
      semantic_form_for(Person.new, :url => people_path) do |f|
        f.input(:attending, :as => :enum)
      end
    }.should raise_error "Attribute 'attending' has no enum class"
  end

  it "should not use enum input type if class does not support ActiveEnum" do
    output = semantic_form_for(NotActiveRecord.new, :as => :not_active_record, :url => people_path) do |f|
      concat f.input(:name)
    end
    output.should have_selector('input#not_active_record_name')
  end

  it "should allow non-enum fields to use default input determination" do
    output = semantic_form_for(Person.new, :url => people_path) do |f|
      concat f.input(:first_name)
    end
    output.should have_selector('input#person_first_name')
  end

  it 'should use translations when available' do
    begin
      I18n.backend.store_translations('en', 'active_enum' => {
          'person' => {'sex' =>{'male' => 'Translated Male', 'female' => 'Translated Female'}}})
      output = semantic_form_for(Person.new, :url => people_path) do |f|
        concat f.input(:sex)
      end
      output.should have_xpath('//option[@value=1]', :content => 'Translated Male')
      output.should have_xpath('//option[@value=2]', :content => 'Translated Female')
    ensure
      I18n.reload!
    end
  end

  def people_path
    '/people'
  end
end
