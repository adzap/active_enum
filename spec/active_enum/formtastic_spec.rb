require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'formtastic'
require 'active_enum/formtastic'

describe ActiveEnum::Formtastic do
  include RSpec::Rails::HelperExampleGroup
  include Formtastic::SemanticFormHelper

  attr_accessor :output_buffer

  before do
    reset_class Person do
      enumerate :sex do
        value :id => 1, :name => 'Male'
        value :id => 2, :name => 'Female'
      end
    end
  end

  it "should use enum class for select option values for enum input type" do
    output = semantic_form_for(Person.new, :url => people_path) do |f|
      concat f.input(:sex, :as => :enum)
    end
    output.should have_selector('select#person_sex')
    output.should have_xpath('//option[@value=1]', :content => 'Male')
    output.should have_xpath('//option[@value=2]', :content => 'Female')
  end

  it "should raise error if attribute for enum input is not enumerated" do
    lambda {
      semantic_form_for(Person.new, :url => people_path) {|f| f.input(:attending, :as => :enum) }
    }.should raise_error "Attribute 'attending' has no enum class"
  end

  def people_path
    '/people'
  end
end
