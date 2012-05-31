module ActiveEnum
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Copy ActiveEnum default files"
      source_root File.expand_path('../templates', __FILE__)

      def copy_initializers
        copy_file 'config.rb', 'config/initializers/active_enum.rb'
      end

    end
  end
end
