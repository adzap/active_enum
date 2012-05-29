module ActiveEnum
  module Generators
    class LocaleGenerator < Rails::Generators::Base
      desc "Copy ActiveEnum locale file for I18n storage"
      source_root File.expand_path('../templates', __FILE__)
      class_option :template_engine

      def copy_initializers
        copy_file 'active_enum.en.yml', 'config/locales/active_enum.en.yml'
      end

    end
  end
end
