module HasFields
  module ClassMethods

    def has_fields(options = {})

      unless options[:scopes].respond_to?(:each)
        raise ArgumentError, 'Must define :scope => [] on the has_fields class method'
      end

      # Provide default options
      options[:fields_class_name] ||= self.name + 'Field'
      options[:fields_table_name] ||= 'fields'
      options[:fields_relationship_name] ||= options[:fields_class_name].underscore.to_sym

      options[:values_class_name] ||= self.name + 'Attribute'
      options[:values_table_name] ||= 'attributes'
      options[:relationship_name] ||= options[:values_class_name].tableize.to_sym
      
      options[:select_options_class_name] ||= self.name + "FieldSelectOption"
      options[:select_options_table_name] ||= 'select_options'
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
        return klass.send("find_all_by_#{scope.class.name.underscore}_id", scope.id, :order => :id)
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
        belongs_to :field, :class_name => '::HasFields::' + options[:fields_class_name].singularize
        def self.reloadable? #:nodoc:
          false
        end
        
        def value
          string_value || text_value || boolean_value || date_value || datetime_value || integer_value || float_value
        end
        
        def value=(v)
          send("#{data_type_from_field_style}_value=",v)
        end
        
        def data_type_from_field_style
          case field.style
          when 'date'
            'date'
          when 'checkbox'
            'boolean'
          else
            'string'
          end
        end

        validates_uniqueness_of options[:foreign_key].to_sym, :scope => :field_id

        def validate
          field = self.field
          raise "Couldn't load field" if !field

          if field.style == "select" && !self.value.blank?
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
          has_many :values, 
            :class_name => '::HasFields::' + options[:values_class_name].singularize,
            :foreign_key => :field_id
          has_many :select_options,
            :class_name => '::HasFields::' + options[:select_options_class_name].singularize,
            :foreign_key => :field_id
          
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
          
          belongs_to :field,
            :class_name => '::HasFields::' + options[:fields_class_name].singularize

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
