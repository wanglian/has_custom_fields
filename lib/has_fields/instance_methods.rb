module HasFields
  module InstanceMethods

    def get_field_attribute(attribute_name, scope, scope_id)
      read_attribute_with_field_behavior(attribute_name, scope, scope_id)
    end

    def set_field_attribute(attribute_name, value, scope, scope_id)
      write_attribute_with_field_behavior(attribute_name, value, scope, scope_id)
    end

    def fields=(fields_data)
      fields_data.each do |scope, scoped_ids|
        scoped_ids.each do |scope_id, attrs|
          attrs.each do |k, v|
            if v.blank?
              value_object = get_value_object(k, scope, scope_id)
              value_object.delete
            else
              self.set_field_attribute(k, v, scope, scope_id)
            end
          end
        end
      end
    end

    def fields
      return ScopeFacade.new(self)
    end

    private

    ##
    # Called after validation on update so that eav attributes behave
    # like normal attributes in the fact that the database is not touched
    # until save is called.
    #
    def save_modified_field_attributes
      return if @save_attrs.nil?
      @save_attrs.each do |s|
        if s.value.nil? || (s.respond_to?(:empty) && s.value.empty?)
          s.destroy if !s.new_record?
        else
          s.save
        end
      end
      @save_attrs = []
    end

    def get_value_object(attribute_name, scope, scope_id)
      options = HasFields.config[self.class.name]
      model_fkey = HasFields.config[self.class.name][:foreign_key].singularize
      fields_class = HasFields.config[self.class.name][:fields_class_name]
      values_class = HasFields.config[self.class.name][:values_class_name]
      value_field = HasFields.config[self.class.name][:value_field]
      fields_fkey = HasFields.config[self.class.name][:fields_table_name].singularize.foreign_key
      fields = Field
      values = FieldAttribute
      f = fields.send("find_by_name_and_#{scope}_id", attribute_name, scope_id)
      
      raise(ActiveRecord::RecordNotFound, "No field #{attribute_name} for #{scope} #{scope_id}") if f.nil?

      field_id = f.id
      model_id = self.id
      value_object = values.send("find_by_#{model_fkey}_and_#{fields_fkey}", model_id, field_id)

      if value_object.nil?
        value_object = values.new model_fkey => self.id,
          fields_fkey => f.id
      end
      return value_object
    end

    ##
    # Overrides ActiveRecord::Base#read_attribute
    #
    def read_attribute_with_field_behavior(attribute_name, scope = nil, scope_id = nil)
      return read_attribute_without_field_behavior(attribute_name) if scope.nil?
      value_object = get_value_object(attribute_name, scope, scope_id)
      case value_object.field.style
      when "date"
        return Date.parse(value_object.value) if value_object.value
      end
      return value_object.value
    end

    ##
    # Overrides ActiveRecord::Base#write_attribute
    #
    def write_attribute_with_field_behavior(attribute_name, value, scope = nil, scope_id = nil)
      return write_attribute_without_field_behavior(attribute_name, value) if scope.nil?

      value_object = get_value_object(attribute_name, scope, scope_id)
      case value_object.field.style
      when "date"
        begin
          new_date = !value["date(1i)"].empty? && !value["date(2i)"].empty? && !value["date(3i)"].empty? ?
            Date.civil(value["date(1i)"].to_i, value["date(2i)"].to_i, value["date(3i)"].to_i) :
            nil
        rescue ArgumentError
          new_date = nil
        end
        value_object.send("value=", new_date) if value_object
      else
        value_object.send("value=", value) if value_object
      end
      @save_attrs ||= []
      @save_attrs << value_object
    end

  end
end
