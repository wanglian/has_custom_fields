module HasCustomFields
  module ClassMethods

    ##
    # Will make the current class have eav behaviour.
    #
    # The following options are available on for has_custom_fields to modify
    # the behavior. Reasonable defaults are provided:
    #
    # * <tt>value_class_name</tt>:
    #   The class for the related model. This defaults to the
    #   model name prepended to "Attribute". So for a "User" model the class
    #   name would be "UserAttribute". The class can actually exist (in that
    #   case the model file will be loaded through Rails dependency system) or
    #   if it does not exist a basic model will be dynamically defined for you.
    #   This allows you to implement custom methods on the related class by
    #   simply defining the class manually.
    # * <tt>table_name</tt>:
    #   The table for the related model. This defaults to the
    #   attribute model's table name.
    # * <tt>relationship_name</tt>:
    #   This is the name of the actual has_many
    #   relationship. Most of the type this relationship will only be used
    #   indirectly but it is there if the user wants more raw access. This
    #   defaults to the class name underscored then pluralized finally turned
    #   into a symbol.
    # * <tt>foreign_key</tt>:
    #   The key in the attribute table to relate back to the
    #   model. This defaults to the model name underscored prepended to "_id"
    # * <tt>name_field</tt>:
    #   The field which stores the name of the attribute in the related object
    # * <tt>value_field</tt>:
    #   The field that stores the value in the related object
    def has_custom_fields(options = {})

      unless options[:scopes].respond_to?(:each)
        raise ArgumentError, 'Must define :scope => [] on the has_custom_fields class method'
      end

      # Provide default options
      options[:fields_class_name] ||= self.name + 'Field'
      options[:fields_table_name] ||= options[:fields_class_name].tableize
      options[:fields_relationship_name] ||= options[:fields_class_name].underscore.to_sym

      options[:values_class_name] ||= self.name + 'Attribute'
      options[:values_table_name] ||= options[:values_class_name].tableize
      options[:relationship_name] ||= options[:values_class_name].tableize.to_sym

      options[:foreign_key] ||= self.name.foreign_key
      options[:base_foreign_key] ||= self.name.underscore.foreign_key
      options[:name_field] ||= 'name'
      options[:value_field] ||= 'value'
      options[:parent] = self.name

      HasCustomFields.log(:debug, "OPTIONS: #{options.inspect}")

      # Init option storage if necessary
      cattr_accessor :custom_field_options
      self.custom_field_options ||= Hash.new

      # Return if already processed.
      return if self.custom_field_options.keys.include? options[:values_class_name]

      # Attempt to load related class. If not create it
      begin
        Object.const_get(options[:values_class_name])
      rescue
        Object.const_set(options[:fields_class_name],
          Class.new(::HasCustomFields::Base)).class_eval do
            self.table_name = options[:fields_table_name]
            def self.reloadable? #:nodoc:
              false
            end

            scopes = options[:scopes].map { |f| f.to_s.foreign_key }
            validates_uniqueness_of :name, :scope => scopes, :message => 'The field name is already taken.'

            validates_inclusion_of :style, :in => ALLOWABLE_TYPES, :message => "Invalid style.  Should be #{ALLOWABLE_TYPES.join(', ')}."
          end
        ::HasCustomFields.const_set(options[:fields_class_name], Object.const_get(options[:fields_class_name]))

        Object.const_set(options[:values_class_name],
        Class.new(ActiveRecord::Base)).class_eval do
          self.table_name = options[:values_table_name]

          cattr_accessor :custom_field_options
          belongs_to options[:fields_relationship_name],
            :class_name => '::HasCustomFields::' + options[:fields_class_name].singularize
          alias_method :field, options[:fields_relationship_name]

          def self.reloadable? #:nodoc:
            false
          end

          validates_uniqueness_of options[:foreign_key].to_sym, :scope => "#{options[:fields_relationship_name]}_id".to_sym

          def validate
            field = self.field
            raise "Couldn't load field" if !field

            if field.style == "select" && !self.value.blank?
              # raise self.field.select_options.find{|f| f == self.value}.to_s
              if field.select_options.find{|f| f == self.value}.nil?
                raise "Invalid option: #{self.value}.  Should be one of #{field.select_options.join(", ")}"
                self.errors.add_to_base("Invalid option: #{self.value}.  Should be one of #{field.select_options.join(", ")}")
                return false
              end
            end
          end
        end
        ::HasCustomFields.const_set(options[:values_class_name], Object.const_get(options[:values_class_name]))
      end

      # Store options
      self.custom_field_options[self.name] = options

      # Modify attribute class
      attribute_class = Object.const_get(options[:values_class_name])
      base_class = self.name.underscore.to_sym

      attribute_class.class_eval do
        belongs_to base_class, :foreign_key => options[:base_foreign_key]
        alias_method :base, base_class # For generic access
      end

      # Modify main class
      class_eval do
        attr_accessible :custom_fields
        has_many options[:relationship_name],
          :class_name => options[:values_class_name],
          :table_name => options[:values_table_name],
          :foreign_key => options[:foreign_key],
          :dependent => :destroy

        # The following is only setup once
        unless method_defined? :read_attribute_without_custom_field_behavior

          # Carry out delayed actions before save
          after_validation :save_modified_custom_field_attributes, :on => :update

          private

          alias_method_chain :read_attribute, :custom_field_behavior
          alias_method_chain :write_attribute, :custom_field_behavior
        end
      end
    end

    def custom_field_fields(scope, scope_id)
      options = custom_field_options[self.name]
      klass = Object.const_get(options[:fields_class_name])
      begin
        return klass.send("find_all_by_#{scope}_id", scope_id, :order => :id)
      rescue NoMethodError
        parent_class = klass.to_s.sub('Field', '')
        raise InvalidScopeError, "Class #{parent_class} does not have scope :#{scope} defined for has_custom_fields"
      end
    end

    private

    def HasCustomFields.log(level, message)
      if defined?(::Rails)
        ::Rails.logger.send(level, message)
      else
        if ENV['debug'] == 'debug'
          STDOUT.puts("HasCustomFields #{level}, #{message}")
        end
      end
    end
  end
end
