require 'rails'
require 'active_record'

require 'has_fields/engine'
require 'has_fields/class_methods'
require 'has_fields/instance_methods'
require 'has_fields/base'

##
# HasFields allow for the Entity-attribute-value model (EAV), also 
# known as object-attribute-value model and open schema on any of your ActiveRecord
# models. 
#
module HasFields

  class InvalidScopeError < ActiveRecord::RecordNotFound; end

  ALLOWABLE_TYPES = ['select', 'checkbox', 'text', 'date']

  Object.const_set('TagFacade', Class.new(Object)).class_eval do
    def initialize(object_with_fields, scope, scope_id)
      @object = object_with_fields
      @scope = scope
      @scope_id = scope_id
    end
    def [](tag)
      return @object.get_field_attribute(tag, @scope, @scope_id)
    end
  end

  Object.const_set('ScopeIdFacade', Class.new(Object)).class_eval do
    def initialize(object_with_fields, scope)
      @object = object_with_fields
      @scope = scope
    end
    def [](scope_id)
      return TagFacade.new(@object, @scope, scope_id)
    end
  end

  Object.const_set('ScopeFacade', Class.new(Object)).class_eval do
    def initialize(object_with_fields)
      @object = object_with_fields
    end
    def [](scope)
      return ScopeIdFacade.new(@object, scope)
    end
  end

end
