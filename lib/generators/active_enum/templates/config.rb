# Form helper integration
# require 'active_enum/form_helpers/simple_form' # for SimpleForm

ActiveEnum.setup do |config|

  # Extend classes to add enumerate method
  # config.extend_classes = [ ActiveRecord::Base ]

  # Return name string as value for attribute method
  # config.use_name_as_value = false

  # Raise exception ActiveEnum::NotFound if enum value for a given id or name is not found
  # config.raise_on_not_found = false

  # Storage of values (:memory, :i18n)
  # config.storage = :memory

end

# ActiveEnum.define do
# 
#   enum(:enum_name) do
#     value 1 => 'Name'
#   end
# 
# end
