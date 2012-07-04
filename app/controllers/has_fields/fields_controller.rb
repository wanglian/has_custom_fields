module HasFields
  class FieldsController < ApplicationController
    before_filter :authenticate_user!
    before_filter :load_fieldable
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
      if @fieldable.update_attributes(params[:fieldable])
        respond_to do |format|
          format.html { redirect_to "/#{@fieldable.class.table_name}/#{@fieldable.id}/fields" }
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

    def resource
      instance_variable_get("@#{base_path.singularize}")
    end

    def tab
      "fields"
    end

    protected
    def load_fieldable
      load(base_path)
      @fieldable = resource
    end

    def load_fields
      @user_fields = Advisor.fields(current_user)
      @organization_fields = Advisor.fields(current_user.organization)
    end
  end
end

