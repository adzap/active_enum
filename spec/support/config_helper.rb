module ConfigHelper
  extend ActiveSupport::Concern

  def with_config(preference_name, temporary_value)
    original_config_value = ActiveEnum.config.send(preference_name)
    
    ActiveEnum.config.send(:"#{preference_name}=", temporary_value)
    yield
  ensure
    ActiveEnum.config.send(:"#{preference_name}=", original_config_value)
  end

  module ClassMethods
    def with_config(preference_name, temporary_value)
      original_config_value = ActiveEnum.config.send(preference_name)

      before(:all) do
        ActiveEnum.config.send(:"#{preference_name}=", temporary_value)
      end

      after(:all) do
        ActiveEnum.config.send(:"#{preference_name}=", original_config_value)
      end
    end
  end
end
