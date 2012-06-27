module HasFields
  module ClassMethods

    ##
    # Will make the current class have eav behaviour.
    #
    # The following options are available on for has_fields to modify
    # the behavior. Reasonable defaults are provided:
    #
    # * <tt>value_class_name</tt>:
    #   The class for the related model. This defaults to the
    #   model name prepended to "Attribute". So for a "User" model the class
    #   name would be "UserAttribute". The class can actually exist (in that
    #   case the model file will be loaded through Rails dependency system) or
    #   if it does not exist a basic model will be dynamically defined for you.
    #   This allows you to implement methods on the related class by
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
    def has_fields(options = {})

      unless options[:scopes].respond_to?(:each)
        raise ArgumentError, 'Must define :scope => [] on the has_fields class method'
      end

      # Provide default options
      options[:fields_class_name] ||= self.name + 'Field'
      options[:fields_table_name] ||= options[:fields_class_name].tableize
      options[:fields_relationship_name] ||= options[:fields_class_name].underscore.to_sym

      options[:values_class_name] ||= self.name + 'Attribute'
      options[:values_table_name] ||= options[:values_class_name].tableize
      options[:relationship_name] ||= options[:values_class_name].tableize.to_sym
      
      options[:select_options_class_name] ||= self.name + "FieldSelectOption"
      options[:select_options_table_name] ||= options[:select_options_class_name].tableize
      options[:select_options_relationship_name] ||= options[:select_options_class_name].pluralize.underscore.to_sym
      
      options[:foreign_key] ||= self.name.foreign_key
      options[:base_foreign_key] ||= self.name.underscore.foreign_key
      options[:name_field] ||= 'name'
      options[:value_field] ||= 'value'
      options[:parent] = self.name

      HasFields.log(:debug, "OPTIONS: #{options.inspect}")

      # Init option storage if necessary
      cattr_accessor :field_options
      self.field_options ||= Hash.new

      # Return if already processed.
      return if self.field_options.keys.include? options[:values_class_name]

      # Attempt to load ModelField related class. If not create it
      begin
        Object.const_get(options[:fields_class_name])
      rescue
        HasFields.create_associated_fields_class(options)
      end

      # Attempt to load ModelAttribute related class. If not create it
      begin
        Object.const_get(options[:values_class_name])
      rescue
        HasFields.create_associated_values_class(options)
      end
      
      # Attempt to load ModelFieldSelectOption related class. If not create it
      begin
        Object.const_get(options[:select_options_class_name])
      rescue
        HasFields.create_associated_select_options_class(options)
      end

      # Store options
      self.field_options[self.name] = options

      # Modify attribute class
      attribute_class = Object.const_get(options[:values_class_name])
      base_class = self.name.underscore.to_sym
      attribute_class.class_eval do
        belongs_to base_class, :foreign_key => options[:base_foreign_key]
        alias_method :base, base_class # For generic access
      end

      # Modify main class
      class_eval do
        attr_accessible :fields
        has_many options[:fields_relationship_name],
          :class_name => options[:values_class_name],
          :table_name => options[:values_table_name],
          :foreign_key => options[:foreign_key],
          :dependent => :destroy

        # The following is only setup once
        unless method_defined? :read_attribute_without_field_behavior

          # Carry out delayed actions before save
          after_validation :save_modified_field_attributes, :on => :update

          private

          alias_method_chain :read_attribute, :field_behavior
          alias_method_chain :write_attribute, :field_behavior
        end
      end
      
      instance_eval do
        has_many options[:relationship_name],
          :class_name => options[:values_class_name],
          :table_name => options[:values_class_name],
          :foreign_key => options[:foreign_key],
          :dependent => :destroy
      end
    end

    def fields(scope=nil)
      unless scope
        raise ArgumentError, 'Please provide a scope for the fields, eg Advisor.fields(@organization)'
      end
      options = field_options[self.name]
      klass = Object.const_get(options[:fields_class_name])
      begin
        return klass.send("find_all_by_#{scope.class.name.downcase}_id", scope.id, :order => :id)
      rescue NoMethodError
        parent_class = klass.to_s.sub('Field', '')
        raise InvalidScopeError, "Class #{parent_class} does not have scope :#{scope.class.name.downcase} defined for has_fields"
      end
    end

    private

    def HasFields.create_associated_values_class(options)
      Object.const_set(options[:values_class_name],
      Class.new(ActiveRecord::Base)).class_eval do
        self.table_name = options[:values_table_name]

        cattr_accessor :field_options
        belongs_to options[:fields_relationship_name],
          :class_name => '::HasFields::' + options[:fields_class_name].singularize
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
      ::HasFields.const_set(options[:values_class_name], Object.const_get(options[:values_class_name]))
    end

    def HasFields.create_associated_fields_class(options)
      Object.const_set(options[:fields_class_name],
        Class.new(::HasFields::Base)).class_eval do
          self.table_name = options[:fields_table_name]
          has_many :values, :class_name => '::HasFields::' + options[:values_class_name].singularize
          has_many :select_options,
            :class_name => '::HasFields::' + options[:select_options_class_name].singularize
          
          def self.reloadable? #:nodoc:
            false
          end
          def related_select_options
            self.send("select_options")
          end
          scopes = options[:scopes].map { |f| f.to_s.foreign_key }
          validates_uniqueness_of :name, :scope => scopes, :message => 'The field name is already taken.'

          validates_inclusion_of :style, :in => ALLOWABLE_TYPES, :message => "Invalid style.  Should be #{ALLOWABLE_TYPES.join(', ')}."
        end
      ::HasFields.const_set(options[:fields_class_name], Object.const_get(options[:fields_class_name]))
    end
    
    def HasFields.create_associated_select_options_class(options)
      Object.const_set(options[:select_options_class_name],
        Class.new(ActiveRecord::Base)).class_eval do
          self.table_name = options[:select_options_table_name]
          
          belongs_to options[:fields_relationship_name],
            :class_name => '::HasFields::' + options[:fields_class_name].singularize
            
          def field
            self.send((attributes.keys.detect{|k| k.match(/_field_id/)}.gsub("_id","")).to_sym)
          end

          validates_presence_of :option, :message => 'The select option cannot be blank.'
          validates_exclusion_of :option, :in => Proc.new{|o| o.field.select_options.map{|opt| opt.option } }, :message => "There should not be any duplicate select options."
        end
      ::HasFields.const_set(options[:select_options_class_name], Object.const_get(options[:select_options_class_name]))
    end

    def HasFields.log(level, message)
      if defined?(::Rails)
        ::Rails.logger.send(level, message)
      else
        if ENV['debug'] == 'debug'
          STDOUT.puts("HasFields #{level}, #{message}")
        end
      end
    end
  end
end
