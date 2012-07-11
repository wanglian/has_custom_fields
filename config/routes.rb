Rails.application.routes.draw do
  match '/:resource/:id/fields/edit' => 'HasFields/fields#edit', :as => :edit_fields, :via => :get
  match '/:resource/:id/fields' => 'has_fields/fields#index', :as => :fields, :via => :get
  match '/:resource/:id/fields' => 'has_fields/fields#update', :as => :update_fields, :via => :put
  match '/:resource/fields/manage' => 'has_fields/manage/fields#index', :as => :manage_fields, :via => :get
  match '/:resource/fields/manage/new' => 'has_fields/manage/fields#new', :as => :new_manage_field, :via => :get
  match '/:resource/fields/manage/:id/edit' => 'has_fields/manage/fields#edit', :as => :edit_manage_field, :via => :get
  match '/:resource/fields/manage' => 'has_fields/manage/fields#create', :as => :create_fields, :via => :put
  match '/:resource/fields/manage/:id' => 'has_fields/manage/fields#update', :as => :update_fields, :via => :put
  match '/:resource/fields/manage/:id' => 'has_fields/manage/fields#show', :as => :manage_field, :via => :get
end
