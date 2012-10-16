module HasFields
  class FieldsController < ApplicationController
    before_filter :authenticate_user!
    before_filter :load_has_fields
    before_filter :load_fields, :only => [:index, :edit]
    layout "application"

    def index
      respond_to do |format|
        format.html { render "/has_fields/fields/_index", :layout => true }
        format.js { render "/has_fields/fields/_index" }
      end
    end

    def edit
      respond_to do |format|
        format.html { render "/has_fields/fields/_edit", :layout => true }
        format.js { render "/has_fields/fields/_edit" }
      end
    end

    def update
      if @scope_object.update_attributes(params[:scope_object])
        respond_to do |format|
          format.html { redirect_to "/#{@scope_object.class.table_name}/#{@scope_object.id}/overview" }
          format.js { render "/has_fields/fields/_index", :locals => {:edit => true} }
        end
      else
        respond_to do |format|
          format.html { render "/has_fields/fields/_edit" }
          format.js { render "/has_fields/fields/_edit", :locals => {:edit => true} }
        end
      end
    end

    def recently_vieweds
      true
    end

    def tab
      "fields"
    end

    protected
    
    def load_has_fields
      @scope = params[:resource].singularize
      @scope_object = instance_variable_get("@#{@scope}")
    end
    
    def load_fields
      @fields = {}
      if HasFields.config[@scope.classify]
        HasFields.config[@scope.classify][:scopes].each do |scope|
          @fields[scope] = @scope.classify.constantize.fields(scope == :user ? current_user : current_user.send(scope))
        end
      end
    end

  end
end

