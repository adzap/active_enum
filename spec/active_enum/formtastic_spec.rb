require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'action_controller'
require 'action_view'
require 'formtastic'
require 'rspec_tag_matchers'
require 'active_enum/formtastic'

describe ActiveEnum::Formtastic do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::ActiveRecordHelper
  include ActionView::Helpers::RecordIdentificationHelper
  include ActionView::Helpers::CaptureHelper
  include ActionController::PolymorphicRoutes
  include Formtastic::SemanticFormHelper
  include RspecTagMatchers

  attr_accessor :output_buffer

  before do
    reset_class Person do
      enumerate :sex do
        value :id => 1, :name => 'Male'
        value :id => 2, :name => 'Female'
      end
    end

    @output_buffer = ''
  end

  it "should use enum class for select option values for enum input type" do
    semantic_form_for(Person.new) do |f|
      concat f.input(:sex, :as => :enum)
    end
    output_buffer.should have_tag('select#person_sex') do |inner|
      inner.should have_tag('//option[@value=1]', 'Male')
      inner.should have_tag('//option[@value=2]', 'Female')
    end
  end

  it "should raise error if attribute for enum input is not enumerated" do
    lambda do
      semantic_form_for(Person.new) {|f| f.input(:attending, :as => :enum) }
    end.should raise_error "Attribute 'attending' has no enum class"
  end

  def protect_against_forgery?
    false
  end

  def people_path
    '/people'
  end
end
