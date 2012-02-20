require 'has_custom_fields/class_methods'
require 'has_custom_fields/instance_methods'
require 'has_custom_fields/base'
require 'has_custom_fields/railtie'

##
# HasCustomFields allow for the Entity-attribute-value model (EAV), also 
# known as object-attribute-value model and open schema on any of your ActiveRecord
# models. 
#
module HasCustomFields

  class InvalidScopeError < ActiveRecord::RecordNotFound; end

  ALLOWABLE_TYPES = ['select', 'checkbox', 'text', 'date']

  Object.const_set('TagFacade', Class.new(Object)).class_eval do
    def initialize(object_with_custom_fields, scope, scope_id)
      @object = object_with_custom_fields
      @scope = scope
      @scope_id = scope_id
    end
    def [](tag)
      # puts "** Calling get_custom_field_attribute for #{@object.class},#{tag},#{@scope},#{@scope_id}"
      return @object.get_custom_field_attribute(tag, @scope, @scope_id)
    end
  end

  Object.const_set('ScopeIdFacade', Class.new(Object)).class_eval do
    def initialize(object_with_custom_fields, scope)
      @object = object_with_custom_fields
      @scope = scope
    end
    def [](scope_id)
      # puts "** Returning a TagFacade for #{@object.class},#{@scope},#{scope_id}"
      return TagFacade.new(@object, @scope, scope_id)
    end
  end

  Object.const_set('ScopeFacade', Class.new(Object)).class_eval do
    def initialize(object_with_custom_fields)
      @object = object_with_custom_fields
    end
    def [](scope)
      # puts "** Returning a ScopeIdFacade for #{@object.class},#{scope}"
      return ScopeIdFacade.new(@object, scope)
    end
  end

end
