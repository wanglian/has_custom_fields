require 'rails/generators/active_record'

module HasFields
  class InstallGenerator < ActiveRecord::Generators::Base
    
    desc "Create a migration to create the has_fields tables to your database.\n" +
         "The NAME argument is the name of your model and the following two arguments\n" +
         "are the scopes that you wish to add to the EAV association\n" +
         "\n" +
         "  rails generate has_fields_generator Post" +
         "\n"
    argument :scoped_model,
             :required => true,
             :type => :string,
             :desc => "The scope you are adding for the field",
             :banner => "scope"
    argument :database_table_prefix,
             :required => false,
             :type => :string,
             :desc => "If you don't want to use the default table names, you can add a prefix here",
             :banner => :database_table_prefix

    def self.source_root
      @source_root ||= File.expand_path('../templates', __FILE__)
    end

    def generate_migration
      migration_template "has_fields_migration.rb.erb", "db/migrate/#{migration_file_name}"
      # migration_template "has_fields_db_constraints.rb.erb", "db/migrate/#{add_db_constraints_migration_file_name}"
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
      "#{database_table_prefix ? "#{database_table_prefix}_" : ''}fields"
    end

    def attributes_table_name
      "#{database_table_prefix ? "#{database_table_prefix}_" : ''}field_attributes"
    end
    
    def select_options_table_name
      "#{database_table_prefix ? "#{database_table_prefix}_" : ''}field_select_options"
    end

    def model_foreign_key
      name.underscore.singularize.foreign_key
    end

    def scope_foreign_key
      scoped_model.singularize.foreign_key
    end

    def migration_name
      "create_fields_for_#{name.underscore}"
    end
    
    def select_options_migration_name
      "create_field_select_options_for_#{name.underscore}"
    end
    
    def data_migration_name
      "migrate_fields_data"
    end
    
    def remove_select_options_from_field_migration_name
      "remove_fields_attribute"
    end
    
    def add_db_constraints_migration_name
      "add_db_constraints_to_fields"
    end

    def migration_file_name
      "#{migration_name}.rb"
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