Rails.application.routes.draw do
  match '/:resource/:id/fields/edit' => 'HasFields/fields#edit', :as => :edit_fields, :via => :get
  match '/:resource/:id/fields' => 'has_fields/fields#index', :as => :fields, :via => :get
  match '/:resource/:id/fields' => 'has_fields/fields#update', :as => :update_fields, :via => :put
  match '/:resource/fields/manage' => 'has_fields/admin/fields#index', :as => :admin_fields, :via => :get
  match '/:resource/fields/manage/new' => 'has_fields/admin/fields#new', :as => :new_admin_field, :via => :get
  match '/:resource/fields/manage/:id/edit' => 'has_fields/admin/fields#edit', :as => :edit_admin_field, :via => :get
  match '/:resource/fields/manage' => 'has_fields/admin/fields#create', :as => :create_fields, :via => :put
  match '/:resource/fields/manage/:id' => 'has_fields/admin/fields#update', :as => :update_fields, :via => :put
  match '/:resource/fields/manage/:id' => 'has_fields/admin/fields#show', :as => :admin_field, :via => :get
end
