module HasFields::Admin
  class FieldsController < ApplicationController
    before_filter :authenticate_user!
    before_filter :load_fields, :only => [:index, :edit, :manage]
    before_filter :load_resource
    layout "application"

    def index
      respond_to do |format|
        format.html { render "/has_fields/admin/fields/_index", :layout => true }
        format.js { render "/has_fields/fields/_index" }
      end
    end
    
    def show
      @field = HasFields::Field.find(params[:id])
      respond_to do |format|
        format.html { render "/has_fields/admin/fields/_show", :layout => true }
        format.js { render "/has_fields/fields/_show" }
      end
    end
    
    def new
      klass = @resource.singularize.classify.constantize
      @field = HasFields::Field.new(:kind => klass)
      @scope_groups = klass.scope_select_options
      respond_to do |format|
        format.html { render "/has_fields/admin/fields/_new", :layout => true }
        format.js { render "/has_fields/fields/_new" }
      end
    end
    
    def create
      @field = HasFields::Field.new(params[:field])
      if @field.save
        respond_to do |format|
          format.html { redirect_to "/advisors/fields/manage/#{@field.id}/" }
          format.js { render "/has_fields/fields/_index", :locals => {:edit => true} }
        end
      else
        respond_to do |format|
          klass = @resource.singularize.classify.constantize
          @scope_groups = klass.scope_select_options
          format.html { render :template => "/has_fields/admin/fields/_new", :layout => true }
          format.js { render "/has_fields/fields/_new", :locals => {:edit => true} }
        end
      end
    end

    def edit
      @field = HasFields::Field.find(params[:id])
      respond_to do |format|
        format.html { render "/has_fields/admin/fields/_edit", :layout => true }
        format.js { render "/has_fields/fields/_edit" }
      end
    end
    
    def update
      @field = HasFields::Field.find(params[:id])
      if @field.update_attributes(params[:field])
        respond_to do |format|
          format.html { redirect_to "/advisors/fields/manage/#{@field.id}/" }
          format.js { render "/has_fields/fields/_index", :locals => {:edit => true} }
        end
      else
        respond_to do |format|
          format.html { render "/has_fields/fields/_edit" }
          format.js { render "/has_fields/fields/_edit", :locals => {:edit => true} }
        end
      end
    end

    protected

    def load_fields
      @user_fields = Advisor.fields(current_user)
      @organization_fields = Advisor.fields(current_user.organization)
    end
    
    def set_resource
      @resource = params[:resource]
    end
  end
end

