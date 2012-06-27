require 'rails/generators/active_record'

module HasFields
  class InstallGenerator < ActiveRecord::Generators::Base
    desc "Create a migration to create the has_fields table to your database.\n" +
         "The NAME argument is the name of your model and the following two arguments\n" +
         "are the scopes that you wish to add to the EAV association\n" +
         "\n" +
         "  rails generate has_fields_generator Post" +
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
      migration_template "has_fields_migration.rb.erb", "db/migrate/#{migration_file_name}"
      migration_template "has_fields_select_options_migration.rb.erb", "db/migrate/#{select_options_migration_file_name}"
      migration_template "migrate_fields_data.rb.erb", "db/migrate/#{data_migration_file_name}"
      migration_template "remove_fields_attribute.rb.erb", "db/migrate/#{remove_select_options_from_custom_field_migration_file_name}"
      migration_template "has_fields_db_constraints.rb.erb", "db/migrate/#{add_db_constraints_migration_file_name}"
    end

    protected
    
    def field_class_name
      "#{name.singularize.capitalize}Field"
    end
    
    def field_relationship_name
      "#{name.underscore.singularize}_field"
    end
    
    def field_select_options_class_name
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
      "create_fields_for_#{name.underscore}"
    end
    
    def select_options_migration_name
      "CreateFieldSelectOptionsFor#{name.capitalize}"
    end
    
    def data_migration_name
      "MigrateFieldsData"
    end
    
    def remove_select_options_from_field_migration_name
      "RemoveFieldsAttribute"
    end
    
    def add_db_constraints_migration_name
      "AddDbConstraintsToFields"
    end

    def migration_file_name
      "#{migration_name}.rb"
    end
    
    def select_options_migration_file_name
      "#{select_options_migration_name.underscore}.rb"
    end
    
    def data_migration_file_name
      "#{data_migration_name.underscore}.rb"
    end
    
    def remove_select_options_from_field_migration_file_name
      "#{remove_select_options_from_field_migration_name.underscore}.rb"
    end
    
    def add_db_constraints_migration_file_name
      "#{add_db_constraints_migration_name.underscore}.rb"
    end

    def migration_class_name
      migration_name.camelize
    end
    
    def select_options_migration_class_name
      migration_name.camelize
    end

  end
end