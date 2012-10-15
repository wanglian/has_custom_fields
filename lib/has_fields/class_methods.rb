module HasFields
  module ClassMethods

    def has_fields(options = {})
      unless options[:scopes].is_a?(Array)
        raise ArgumentError, "Must define :scope => [] on the has_fields class method"
      end
      
      HasFields.config||={}
      HasFields.config[self.name] = default_config.merge(options)

      base_class = self.name

      # Attempt to load Field related class. If not create it
      begin
        Object.const_get("Field")
      rescue
        HasFields.create_associated_fields_class(base_class)
      end

      # Attempt to load FieldAttribute related class. If not create it
      begin
        Object.const_get("FieldAttribute")
      rescue
        HasFields.create_associated_values_class(base_class)
      end
      
      # Attempt to load the FieldSelectOption related class. If not create it
      begin
        Object.const_get("FieldSelectOption")
      rescue
        HasFields.create_associated_select_options_class(base_class)
      end

      # Modify main class
      class_eval do
        attr_accessible :fields

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
        has_many :field_attributes, :dependent => :destroy
      end
      
      # attach the field attributes to the class - needs to be done here so that the belongs_to doesn't get overwritten each time has_lists is called
      FieldAttribute.class_eval do
        belongs_to base_class.underscore.to_sym, :foreign_key => HasFields.config[base_class][:foreign_key]
      end
      
    end

    def fields(scope=nil)
      unless scope
        raise ArgumentError, "Please provide a scope for the fields, eg Advisor.fields(@organization)"
      end
  
      begin
        return Field.send("find_all_by_#{scope.class.name.underscore}_id_and_kind", scope.id, self.name, :order => :id)
      rescue NoMethodError
        raise InvalidScopeError, "Class #{self.name} does not have scope :#{scope.class.name.downcase} defined for has_fields"
      end
    end

    private
    
    def HasFields.create_associated_fields_class(klass)
      Object.const_set(HasFields.config[klass][:fields_class_name],
        Class.new(::HasFields::Base)).class_eval do
          self.table_name = HasFields.config[klass][:fields_table_name]
          has_many :field_select_options, :class_name => "::HasFields::FieldSelectOption", :foreign_key => :field_id, :dependent => :destroy
          has_many :field_attributes, :class_name => "::HasFields::FieldAttribute", :foreign_key => :field_id, :dependent => :destroy
          belongs_to klass.underscore.to_sym
          scope :by_scope, lambda {|s| {:conditions => "#{s}_id IS NOT NULL"}}
          validates_presence_of :kind, :message => 'Please specify the class that this field will be added to.'
          validates_presence_of :name
          validates_uniqueness_of :name, :scope => HasFields.config[klass][:scopes].map { |f| f.to_s.foreign_key }, :message => "The field name is already taken."
          validates_inclusion_of :style, :in => ALLOWABLE_TYPES, :message => "should be one of: #{ALLOWABLE_TYPES.join(", ")}."
          validate :no_duplicate_select_options
          validate :select_options_present
          accepts_nested_attributes_for :field_select_options, :reject_if => proc {|o| o['option'].blank? }, :allow_destroy => true
          
          def self.reloadable? #:nodoc:
            false
          end
          
          def self.scoped_by(scope_object)
            foreign_key = "#{scope_object.class.name.downcase}_id"
            where(foreign_key => scope_object.id)
          end
          
          def scoped_by_class
            attributes.detect{|k,v| k.match(/_id/) && !v.nil?}[0].gsub("_id","")
          end
          
          def scoped_by_object
            scoped_by_class.classify.constantize.send(:find,eval("#{scoped_by_class}_id"))       
          end
          
          def scope_id=(scope_class_and_id)
            scope_class, scope_id = scope_class_and_id.split("_")
            self.send("#{scope_class.underscore}_id=", scope_id)
          end
          
          def select_options_data
            HasFields::FieldSelectOption.find_all_by_field_id(id).map{|o| o.option }
          end
          
          def no_duplicate_select_options
            if style == 'select' && (field_select_options.size != field_select_options.map{|o| o.option}.uniq.size)
              errors[:base] << "There are duplicate select options."
            end
          end
          
          def select_options_present
            if style == 'select' && (field_select_options.size == 0)
              errors[:base] << "There must be at least one select option."
            end
          end

        end
      ::HasFields.const_set("Field", Object.const_get("Field"))
    end

    def HasFields.create_associated_values_class(klass)
      Object.const_set(HasFields.config[klass][:attributes_class_name],
      Class.new(ActiveRecord::Base)).class_eval do
        self.table_name = HasFields.config[klass][:attributes_table_name]
        validates_presence_of :field_id
        validates_inclusion_of :value, :in => Proc.new{|v| v.field.field_select_options.map{|opt| opt.option }}, :if => Proc.new{|o| o.field && o.field.style == "select" }
        belongs_to :field, :class_name => "::HasFields::Field"
        
        def self.reloadable? #:nodoc:
          false
        end
        
        def value
          string_value || boolean_value || date_value || decimal_value
        end
        
        def value=(v)
          send("#{data_type_from_field_style}_value=", v)
        end
        
        def data_type_from_field_style
          return "string" unless field
          case field.style
          when "date"
            "date"
          when "checkbox"
            "boolean"
          when "decimal"
            "float"
          else
            "string"
          end
        end

      end
      ::HasFields.const_set("FieldAttribute", Object.const_get("FieldAttribute"))
    end
    
    def HasFields.create_associated_select_options_class(klass)
      Object.const_set(HasFields.config[klass][:select_options_class_name],
        Class.new(ActiveRecord::Base)).class_eval do
          self.table_name = HasFields.config[klass][:select_options_table_name]
          belongs_to :field, :class_name => "::HasFields::Field"
          
          validates_presence_of :option, :message => "The select option cannot be blank."
          validates_exclusion_of :option, :in => Proc.new{|o| o.field ? o.field.field_select_options.map{|opt| opt.option } : []}, :message => "There should not be any duplicate select options."
        
        end
      ::HasFields.const_set("FieldSelectOption", Object.const_get("FieldSelectOption"))
    end

    def default_config
      {
       :fields_class_name => "Field",
       :fields_table_name => "fields",
       :fields_relationship_name => :fields,
       :attributes_class_name => "FieldAttribute",
       :attributes_table_name => "field_attributes",
       :attributes_relationship_name => :field_attributes,
       :select_options_class_name => "FieldSelectOption",
       :select_options_table_name => :field_select_options,
       :select_options_relationship_name => :field_select_options,
       :foreign_key => self.name.foreign_key
      }
    end
    
  end
end
