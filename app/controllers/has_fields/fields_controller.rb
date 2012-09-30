module HasFields
  class FieldsController < ApplicationController
    before_filter :authenticate_user!, :set_params
    before_filter :load_has_fields
    before_filter :load_fields, :only => [:index, :edit, :manage]
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
      if @fieldable.update_attributes(params[:fieldable])
        respond_to do |format|
          format.html { redirect_to "/#{@fieldable.class.table_name}/#{@fieldable.id}/overview" }
          format.js { render "/has_fields/fields/_index", :locals => {:edit => true} }
        end
      else
        respond_to do |format|
          load_fields
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
    # this is your hook to load whatever info you need to render the page
    def load_has_fields
      # need to set the base object
    end

    def load_fields
      @fields = {}
      if HasFields.config[@resource.classify]
        HasFields.config[@resource.classify][:scopes].each do |scope|
          @fields[scope] = @resource.classify.constantize.fields(scope == :user ? current_user : current_user.send(scope))
        end
      end
    end

    def set_params
      @resource = params[:resource]
    end
  end
end

