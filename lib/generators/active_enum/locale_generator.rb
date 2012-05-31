module ActiveEnum
  module Generators
    class LocaleGenerator < Rails::Generators::Base
      desc "Copy ActiveEnum locale file for I18n storage"
      source_root File.expand_path('../templates', __FILE__)
      class_option :lang, :type => :string, :default => 'en', :desc => "Language for locale file"

      def copy_initializers
        template 'locale.yml',  locale_full_path
      end

      def locale_filename
        "active_enum.#{options[:lang]}.yml"
      end

      def locale_full_path
        "config/locales/#{locale_filename}"
      end
    end
  end
end
