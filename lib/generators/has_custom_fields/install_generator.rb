require 'rails/generators/active_record'

module HasCustomFields
  class InstallGenerator < ActiveRecord::Generators::Base
    desc "Create a migration to create the has_custom_fields table to your database.\n" +
         "The NAME argument is the name of your model and the following two arguments\n" +
         "are the scopes that you wish to add to the EAV association\n" +
         "\n" +
         "  rails generate has_custom_fields_generator Post" +
         "\n"
         
    argument :scoped_models,
             :required => true,
             :type => :array,
             :desc => "The scopes you are adding for the fields",
             :banner => "scope1 scope2"

    def self.source_root
      @source_root ||= File.expand_path('../templates', __FILE__)
    end

    def generate_migration
      migration_template "has_custom_fields_migration.rb.erb", "db/migrate/#{migration_file_name}"
    end

    protected
    
    def custom_field_class_name
      "#{name.singularize.capitalize}Field"
    end
    
    def custom_field_relationship_name
      "#{name.singularize}"
    end
    
    def custom_field_select_options_class_name
      "#{name.singularize.capitalize}FieldSelectOption"
    end

    def field_table_name
      "#{name.underscore.singularize}_fields"
    end

    def attributes_table_name
      "#{name.underscore.singularize}_attributes"
    end
    
    def select_options_table_name
      "#{name.underscore.singularize}_field_select_options"
    end

    def model_foreign_key
      name.underscore.singularize.foreign_key
    end

    def scope_foreign_keys
      scoped_models.map { |scope| scope.singularize.foreign_key }
    end

    def migration_name
      "create_custom_fields_for_#{name.underscore}"
    end
    
    def select_options_migration_name
      "create_custom_field_select_options_for_#{name.underscore}"
    end

    def migration_file_name
      "#{migration_name}.rb"
    end
    
    def select_options_migration_file_name
      "#{select_options_migration_name}.rb"
    end

    def migration_class_name
      migration_name.camelize
    end
    
    def select_options_migration_class_name
      migration_name.camelize
    end

  end
end