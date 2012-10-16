module HasFields::Manage
  class FieldsController < HasFields::ApplicationController
    before_filter :authenticate_user! 
    before_filter :load_has_fields

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
      if params[:save] == "save" && @field.save
        respond_to do |format|
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
      if params[:save] && @field.update_attributes(params[:field])
        respond_to do |format|
          flash[:success] = 'Field was successfully updated.'
          format.html { redirect_to "/#{@scope.pluralize}/#{@scope_object.id}/fields/manage?resource=#{@field.kind}" }
          format.js { render "/has_fields/manage/fields/_index", :locals => {:edit => true} }
        end
      else
        respond_to do |format|
          format.html { render "/has_fields/manage/fields/_edit" }
          format.js { render "/has_fields/manage/fields/_edit", :locals => {:edit => true} }
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
    
    def load_has_fields
      @field = HasFields::Field.find(params[:id]) unless !params[:id]
      @resource = params[:resource]
      @resources = HasFields.config.keys.sort
      @scope = params[:scope].singularize
      @scope_object = scope.singularize.classify.constantize.find(params[:scope_id])
      @resources.each{|r| instance_variable_set("@#{r.underscore}_fields", Field.scoped_by(@scope_object).where(:kind => r).paginate(:page => params[:page]))}
    end

  end
end

