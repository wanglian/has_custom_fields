module HasFields::Manage
  class FieldsController < HasFields::ApplicationController
    before_filter :authenticate_user!
    before_filter :load_resource_and_scope
    before_filter :load_fields, :only => [:index, :edit]
    before_filter :load_field, :only => [:show, :edit, :update, :destroy]
    layout "application"

    def index
      respond_to do |format|
        format.html { render "/has_fields/manage/fields/_index", :layout => true }
        format.js { render "/has_fields/manage/fields/_index" }
      end
    end

    def show
      respond_to do |format|
        format.html { render "/has_fields/manage/fields/_show", :layout => true }
        format.js { render "/has_fields/manage/fields/_show" }
      end
    end

    def new
      @field = HasFields::Field.new
      respond_to do |format|
        format.html { render "/has_fields/manage/fields/_new", :layout => true }
        format.js { render "/has_fields/manage/fields/_new" }
      end
    end

    def create
      @field = HasFields::Field.new(params[:field].merge("#{@scope}_id".to_sym => @scope_object.id))
      @field.field_select_options.build unless !params[:add_select_option]
      if (@field.style != 'select' || @field.field_select_options.any?) && params[:save] == 'save' && @field.save
        respond_to do |format|
          flash[:success] = 'Field was successfully created.'
          format.html { redirect_to "/#{@scope.pluralize}/#{@scope_object.id}/fields/manage?resource=#{@field.kind}"}
          format.js { render "/has_fields/manage/fields/_index", :locals => {:edit => true} }
        end
      else
        respond_to do |format|
          format.html { render :template => "/has_fields/manage/fields/_new", :layout => true }
          format.js { render "/has_fields/manage/fields/_new", :locals => {:edit => true} }
        end
      end
    end

    def edit
      respond_to do |format|
        format.html { render "/has_fields/manage/fields/_edit", :layout => true }
        format.js { render "/has_fields/manage/fields/_edit" }
      end
    end

    def update
      @field.field_select_options.build unless !params[:add_select_option]
      if params[:save] && @field.update_attributes(params[:field])
        respond_to do |format|
          flash[:success] = 'Field was successfully updated.'
          format.html { redirect_to "/#{@scope.pluralize}/#{@scope_object.id}/fields/manage?resource=#{@field.kind}" }
          format.js { render "/has_fields/fields/manage/_index", :locals => {:edit => true} }
        end
      else
        respond_to do |format|
          format.html { render "/has_fields/manage/fields/_edit" }
          format.js { render "/has_fields/fields/manage/_edit", :locals => {:edit => true} }
        end
      end
    end

    def destroy
      if @field.destroy
        respond_to do |format|
          flash[:success] = 'Field was successfully removed.'
          format.html { redirect_to "/#{@scope.pluralize}/#{@scope_object.id}/fields/manage?resource=#{@field.kind}" }
          format.js { redirect_to "/has_fields/manage/fields/_index" }
        end
      else
        respond_to do |format|
          format.html { render "/has_fields/manage/fields/_edit", :layout => true }
          format.js { render "/has_fields/manage/fields/_edit" }
        end
      end
    end

    def tab
      "fields"
    end

    protected

    def load_fields
      # for each resource, find all fields applicable to the current user that are scoped by the supplied scope
      @resources.each{|r| instance_variable_set("@#{r.underscore}_fields", Field.scoped_by(@scope_object).where(:kind => r).paginate(:page => params[:page]))}
    end
    
    def load_field
      @field = HasFields::Field.find(params[:id])
    end
    
    def load_resource_and_scope
      @resource = params[:resource]
      @resources = HasFields.config.keys.sort
      @scope = params[:scope].singularize
      load_resource(@scope)
      # the scope object should be either the current user, a user from their org, or their org.
      @scope_object = @scope.classify.constantize.find(params[:scope_id])
    end
  end
end

