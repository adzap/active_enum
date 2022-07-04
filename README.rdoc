= ActiveEnum

Define enum classes in Rails and use them to enumerate ActiveRecord attributes. Brings together some ideas
of similar plugins that I liked and does it they way I prefer.

Enum values are stored in memory at the moment but I plan to add database and possibly others. See Storage Backends.

== Install

Supports Ruby versions 2.0+.

From gem version 1.0 onwards this plugin will only have Rails 4+ support. If you need Rails 3 compatibility, {check the 0.9 branch}[https://github.com/adzap/active_enum/tree/0.9].

  gem install active_enum 

Put this in your Gemfile

  gem 'active_enum', '~> 1.0.0'

Then generate the config initializer file

  rails generate active_enum:install


== Example

Define an enum class with values

  class Sex < ActiveEnum::Base
    value :id => 1, :name => 'Male'
    value :id => 2, :name => 'Female'
  end

Define with id as the key

  class Sex < ActiveEnum::Base
    value 1 => 'Male'
    value 2 => 'Female'
  end

Define using implicit id values

  class Sex < ActiveEnum::Base
    value :name => 'Male'
    value :name => 'Female'
  end

Beware that if you change the order of values defined in an enum which don't have explicit ids, then the ids will change.
This could corrupt your data if the enum values have been stored in a model record, as they will no longer map to
the original enum.

Define values with meta data

  class Sex < ActiveEnum::Base
    value :id => 1, :name => 'Male',   :symbol => '♂'
    value :id => 2, :name => 'Female', :symbol => '♀'
  end

The meta data can be any other key-value pairs, it's not limited to certain keys.

Enum class usage

  Sex[1]        # => 'Male'
  Sex['Male']   # => 1
  Sex[:male]    # => 1
  Sex.meta(1)   # => { :symbol => '♂' }
  Sex.to_select # => [['Male', 1], ['Female',2]] for select form helpers

=== Ordering

To define the sorting of returned values use the order method. Which is useful for to_select method.

  class Sex < ActiveEnum::Base
    order :asc

    value :id => 1, :name => 'Male'
    value :id => 2, :name => 'Female'
  end

By default the order is ascending (:asc) but you can also choose descending (:desc) or in natural order of definition (:natural).
The last option is useful when supplying id values but have a specific order needed to display them.

=== Enumerate model attributes

Use the enum to enumerate an ActiveRecord model attribute

  class User < ActiveRecord::Base
    enumerate :sex, :with => Sex
  end

Skip the with option if the enum can be implied from the attribute

  class User < ActiveRecord::Base
    enumerate :sex
  end

Define enum class implicitly from enumerate block. Enum class is namespaced by model class.

  class User < ActiveRecord::Base

    # defines User::Sex enum class
    enumerate :sex do
      value :name => 'Male'
    end
  end

Multiple attributes with same enum

  class Patient < ActiveRecord::Base
    enumerate :to, :from, :with => Sex
  end


=== Validations

You can use an enum in a validation of inclusion like so

  class User < ActiveRecord::Base
    enumerate :sex, :with => Sex

    validates_inclusion_of :sex, :in => Sex
  end

This works because an enum class responds to #include?().


=== Attribute value lookup

Access the enum values and the enum class using the attribute method with a symbol for the enum component you want

  user = User.new
  user.sex = 1
  user.sex          # => 1

  user.sex(:id)     # => 1
  user.sex(:name)   # => 'Male'
  user.sex(:enum)   # => Sex
  user.sex(:symbol) # => ♂  ( Can use any meta data key )

You can set the default to return the enum name value for enumerated attributes

  ActiveEnum.setup do |config|
    config.use_name_as_value = true
  end

And now the name is returned for the regular attribute read method.

  user.sex # => 'Male'


=== Boolean check

You can check if the attribute value matches a particular enum value by passing the enum value as an argument to the question method

  user.sex?(:male)    # => true
  user.sex?(:Male)    # => true
  user.sex?('Male')   # => true
  user.sex?('Female') # => false

=== Enum lookup

A convenience method on the class is available to the enum class of any enumerated attribute

  User.active_enum_for(:sex) # => Sex

== Raise exception when value not found

When a value if not found for a given id or name the default behaviour is to return nil. If you would like to raise an error use

  ActiveEnum.setup do |config|
    config.raise_on_not_found = true
  end

Then for the following examples
  
  Sex['Other']

  # Or

  Sex[3]

will raise an ActiveEnum::NotFound exception.


=== Bulk definition

Define enum classes in bulk without class files, in an initializer file for example.

  ActiveEnum.define do

    # defines Sex
    enum(:sex) do
      value :name => 'Male'
      value :name => 'Female'
    end

    # defines Language
    enum(:language) do
      value :name => 'English'
      value :name => 'German'
    end

  end

All defined enum classes are stored in ActiveEnum.enum_classes array if you need look them up or iterate over them.

=== Model as enum or acts_as_enum

You can make an existing model class behave like an enum class with acts_as_enum

  class Country < ActiveRecord::Base
    acts_as_enum :name_column => 'short_name'
  end

Giving you the familiar enum methods

  Country[1]
  Country['Australia']
  Country.to_select


=== Form Helpers

There is support for SimpleForm[http://github.com/plataformatec/simple_form] version 3+.
to make it easier to use the enum values as select options. 

In the initializer:

  require 'active_enum/form_helpers/simple_form'

The input type will be automatically detected for enumerated attributes. You can override with the :as option as normal.


== Storage Backends 

The design allows pluggable backends to be used for stories and retrieving the enum values. At present there are two
available, memory or I18n. To change the storage engine you alter the storage config value like so:

  ActiveEnum.setup do |config|
    config.storage = :i18n
  end

The memory store is default obviously just stores the values in memory.


=== I18n Storage

The I18n storage backend stores the ids and names is memory still, but retrieves the name text translation any call to
the enum public methods. 

To set up the locale file, run

  rails g active_enum:locale

This generates the YML locale template in your default language as configured in the application.rb.

Here are some examples of defining enum translations
 
   class Sex < ActiveEnum::Base
     value 1 => 'male'
     value 2 => 'female'
   end
 
becomes 

  sex:
    male: Male 
    female: Female 

For namesapced enums in a model

  class Person < ActiveRecord::Base
    enumerate :sex do
      value 1 => 'male'
      value 2 => 'female'
    end
  end

nest the translations under the underscored model name
  
  person:
    sex:
      male: Male 
      female: Female 


== License

Copyright (c) 2009 Adam Meehan, released under the MIT license
