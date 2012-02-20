module HasCustomFields
  module InstanceMethods

    def get_custom_field_attribute(attribute_name, scope, scope_id)
      read_attribute_with_custom_field_behavior(attribute_name, scope, scope_id)
    end

    def set_custom_field_attribute(attribute_name, value, scope, scope_id)
      write_attribute_with_custom_field_behavior(attribute_name, value, scope, scope_id)
    end

    def custom_fields=(custom_fields_data)
      custom_fields_data.each do |scope, scoped_ids|
        scoped_ids.each do |scope_id, attrs|
          attrs.each do |k, v|
            if v.blank?
              # TODO: Delete any record that exists if value is being set to nil
            else
              self.set_custom_field_attribute(k, v, scope, scope_id)
            end
          end
        end
      end
    end

    def custom_fields
      return ScopeFacade.new(self)
    end

    private

    ##
    # Called after validation on update so that eav attributes behave
    # like normal attributes in the fact that the database is not touched
    # until save is called.
    #
    def save_modified_custom_field_attributes
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
      HasCustomFields.log(:debug, "scope/id is: #{scope}/#{scope_id}")
      options = custom_field_options[self.class.name]
      model_fkey = options[:foreign_key].singularize
      fields_class = options[:fields_class_name]
      values_class = options[:values_class_name]
      value_field = options[:value_field]
      fields_fkey = options[:fields_table_name].singularize.foreign_key
      fields = Object.const_get(fields_class)
      values = Object.const_get(values_class)
      HasCustomFields.log(:debug, "fkey is: #{fields_fkey}")
      HasCustomFields.log(:debug, "fields class: #{fields.to_s}")
      HasCustomFields.log(:debug, "values class: #{values.to_s}")
      HasCustomFields.log(:debug, "scope is: #{scope}")
      HasCustomFields.log(:debug, "scope_id is: #{scope_id}")
      HasCustomFields.log(:debug, "attribute_name is: #{attribute_name}")

      f = fields.send("find_by_name_and_#{scope}_id", attribute_name, scope_id)
      
      raise(ActiveRecord::RecordNotFound, "No field #{attribute_name} for #{scope} #{scope_id}") if f.nil?

      HasCustomFields.log(:debug, "field: #{f.inspect}")
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
    def read_attribute_with_custom_field_behavior(attribute_name, scope = nil, scope_id = nil)
      return read_attribute_without_custom_field_behavior(attribute_name) if scope.nil?
      value_object = get_value_object(attribute_name, scope, scope_id)
      case value_object.field.style
      when "date"
        HasCustomFields.log(:debug, "reading date object: #{value_object.value}")
        return Date.parse(value_object.value) if value_object.value
      end
      return value_object.value
    end

    ##
    # Overrides ActiveRecord::Base#write_attribute
    #
    def write_attribute_with_custom_field_behavior(attribute_name, value, scope = nil, scope_id = nil)
      return write_attribute_without_custom_field_behavior(attribute_name, value) if scope.nil?

      HasCustomFields.log(:debug, "attribute_name(#{attribute_name}) value(#{value.inspect}) scope(#{scope}) scope_id(#{scope_id})")
      value_object = get_value_object(attribute_name, scope, scope_id)
      case value_object.field.style
      when "date"
        HasCustomFields.log(:debug, "date object: #{value["date(1i)"].to_i}, #{value["date(2i)"].to_i}, #{value["date(3i)"].to_i}")
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
