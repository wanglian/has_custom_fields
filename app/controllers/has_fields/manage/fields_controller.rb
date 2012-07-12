module HasFields::Manage
  class FieldsController < HasFields::ApplicationController
    before_filter :authenticate_user!
    before_filter :load_resource
    before_filter :load_fields, :only => [:index, :edit, :manage]
    layout "application"

    def index
      respond_to do |format|
        format.html { render "/has_fields/manage/fields/_index", :layout => true }
        format.js { render "/has_fields/manage/fields/_index" }
      end
    end
    
    def show
      @field = HasFields::Field.find(params[:id])
      respond_to do |format|
        format.html { render "/has_fields/manage/fields/_show", :layout => true }
        format.js { render "/has_fields/manage/fields/_show" }
      end
    end
    
    def new
      klass = @resource.singularize.classify.constantize
      @field = HasFields::Field.new(:kind => klass)
      respond_to do |format|
        format.html { render "/has_fields/manage/fields/_new", :layout => true }
        format.js { render "/has_fields/manage/fields/_new" }
      end
    end
    
    def create
      @field = HasFields::Field.new(params[:field])
      if @field.save
        respond_to do |format|
          format.html { redirect_to "/#{@field.scoped_by_class}/fields/#{@resource}/manage/#{@field.id}/" }
          format.js { render "/has_fields/manage/fields/_index", :locals => {:edit => true} }
        end
      else
        respond_to do |format|
          klass = @resource.singularize.classify.constantize
          @scope_groups = klass.scope_select_options
          format.html { render :template => "/has_fields/manage/fields/_new", :layout => true }
          format.js { render "/has_fields/manage/fields/_new", :locals => {:edit => true} }
        end
      end
    end

    def edit
      @field = HasFields::Field.find(params[:id])
      respond_to do |format|
        format.html { render "/has_fields/manage/fields/_edit", :layout => true }
        format.js { render "/has_fields/manage/fields/_edit" }
      end
    end
    
    def update
      @field = HasFields::Field.find(params[:id])
      if @field.update_attributes(params[:field])
        respond_to do |format|
          format.html { redirect_to "/#{@field.scoped_by_class}/fields/#{@resource}/manage/#{@field.id}/" }
          format.js { render "/has_fields/fields/manage/_index", :locals => {:edit => true} }
        end
      else
        respond_to do |format|
          format.html { render "/has_fields/fields/manage/_edit" }
          format.js { render "/has_fields/fields/manage/_edit", :locals => {:edit => true} }
        end
      end
    end
    
    protected

    def load_fields
      @fields = @resource.classify.constantize.fields(@scope == 'user' ? current_user : current_user.send(@scope))
    end
    
    def load_resource
      @resource = params[:resource]
      @scope = params[:scope]
    end
  end
end

