module HasFields
  module ClassMethods

    def has_fields(options = {})
      unless options[:scopes].is_a?(Array)
        raise ArgumentError, "Must define :scope => [] on the has_fields class method"
      end
      
      HasFields.config||={}
      HasFields.config[self.name] = default_config(self.name).merge(options)

      base_class = self.name

      # Attempt to load Field related class. If not create it
      begin
        Object.const_get(Field)
      rescue
        HasFields.create_associated_fields_class(base_class)
      end

      # Attempt to load FieldAttribute related class. If not create it
      begin
        Object.const_get(FieldAttribute)
      rescue
        HasFields.create_associated_values_class(base_class)
      end
      
      # Attempt to load the FieldSelectOption related class. If not create it
      begin
        Object.const_get(FieldSelectOption)
      rescue
        HasFields.create_associated_select_options_class(base_class)
      end

      # Modify attribute class
      FieldAttribute.class_eval do
        belongs_to base_class.underscore, :foreign_key => HasFields.config[base_class][:foreign_key]
        alias_method :base, base_class.underscore # For generic access
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
    
    # Builds an array of objects that a field can be scoped by, to be used in a grouped select box in the form.
    # It is expensive if there are a lot of objects and assumes the object has a field name or method,
    # so you might want to define your own /has_fields/admin/fields/scope_select partial
    def scope_select_options
      scopes = Array(field_options[self.name][:scopes])
      scope_groups = []
      scopes.each_with_index do |s,index|
        scope_groups << [s.to_s.capitalize.pluralize]
        scope_groups[index] << s.to_s.classify.constantize.all.sort_by(&:name).collect{|s| [s.name,"#{s.class}_#{s.id}"]}
      end
      scope_groups
    end

    private
    
    def HasFields.create_associated_fields_class(klass)
      Object.const_set(HasFields.config[klass][:fields_class_name],
        Class.new(::HasFields::Base)).class_eval do
          self.table_name = HasFields.config[klass][:fields_table_name]
          has_many :field_attributes, :class_name => "::HasFields::FieldAttribute", :foreign_key => :field_id
          has_many :select_options, :class_name => "::HasFields::FieldSelectOption", :foreign_key => :field_id
          belongs_to klass.underscore.to_sym
          
          validates_presence_of :kind, :message => 'Please specify the class that this field will be added to.'
          validates_presence_of :name, :message => 'Please specify the field name.'
          validates_presence_of :select_options_data, :if => proc {|p| p.style == "select"}, :message => "You must enter options for the selection."
          validates_uniqueness_of :name, :scope => HasFields.config[klass][:scopes].map { |f| f.to_s.foreign_key }, :message => "The field name is already taken."
          validates_inclusion_of :style, :in => ALLOWABLE_TYPES, :message => "Invalid style.  Should be #{ALLOWABLE_TYPES.join(", ")}."
          
          def self.reloadable? #:nodoc:
            false
          end
          
          def related_select_options
            self.send("select_options")
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
            (self.related_select_options.collect{|o| o.option } || [])
          end

        end
      ::HasFields.const_set("Field", Object.const_get("Field"))
    end

    def HasFields.create_associated_values_class(klass)
      Object.const_set(HasFields.config[klass][:attributes_class_name],
      Class.new(ActiveRecord::Base)).class_eval do
        self.table_name = HasFields.config[klass][:attributes_table_name]
      
        belongs_to :field, :class_name => "::HasFields::Field"
        belongs_to klass.underscore.to_sym, :foreign_key => HasFields.config[klass][:foreign_key]
        
        alias_method :base, klass.underscore.to_sym
        
        validates_uniqueness_of HasFields.config[klass][:foreign_key], :scope => :field_id, :foreign_key => self.name.foreign_key
        
        def self.reloadable? #:nodoc:
          false
        end
        
        def value
          string_value || boolean_value || date_value
        end
        
        def value=(v)
          send("#{data_type_from_field_style}_value=", v)
        end
        
        def data_type_from_field_style
          case field.style
          when "date"
            "date"
          when "checkbox"
            "boolean"
          else
            "string"
          end
        end

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
      ::HasFields.const_set("FieldAttribute", Object.const_get("FieldAttribute"))
    end
    
    def HasFields.create_associated_select_options_class(klass)
      Object.const_set(HasFields.config[klass][:select_options_class_name],
        Class.new(ActiveRecord::Base)).class_eval do
          self.table_name = HasFields.config[klass][:select_options_table_name]
          
          belongs_to :field, :class_name => "::HasFields::Field"

          validates_presence_of :option, :message => "The select option cannot be blank."
          validates_exclusion_of :option, :in => Proc.new{|o| o.field.select_options.map{|opt| opt.option } }, :message => "There should not be any duplicate select options."
        end
      ::HasFields.const_set("FieldSelectOption", Object.const_get("FieldSelectOption"))
    end

    def default_config(class_name)
      {
       :fields_class_name => "Field",
       :fields_table_name => "fields",
       :fields_relationship_name => :fields,
       :attributes_class_name => "FieldAttribute",
       :attributes_table_name => "field_attributes",
       :attributes_relationship_name => :field_attributes,
       :select_options_class_name => "FieldSelectOption",
       :select_options_table_name => "field_select_options",
       :select_options_relationship_name => ":field_select_options",
       :foreign_key => self.name.foreign_key
      }
    end
    
    def HasFields.log(level, message)
      if defined?(::Rails)
        ::Rails.logger.send(level, message)
      else
        if ENV["debug"] == "debug"
          STDOUT.puts("HasFields #{level}, #{message}")
        end
      end
    end
  end
end
