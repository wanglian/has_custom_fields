class Document < ActiveRecord::Base
  has_custom_fields

  def is_custom_field_attribute?(attr_name, model)
    attr_name =~ /attr$/
  end
end