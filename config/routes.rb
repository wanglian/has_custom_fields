Rails.application.routes.draw do
  match '/:scope/:scope_id/fields/:resource/manage' => 'has_fields/manage/fields#index', :as => :manage_fields, :via => :get
  match '/:scope/:scope_id/fields/:resource/manage/new' => 'has_fields/manage/fields#new', :as => :new_manage_fields, :via => :get
  match '/:scope/:scope_id/fields/:resource/manage' => 'has_fields/manage/fields#create', :as => :manage_fields, :via => :post
  match '/:scope/:scope_id/fields/:resource/manage/:id/edit' => 'has_fields/manage/fields#edit', :as => :edit_manage_fields, :via => :get
  match '/:scope/:scope_id/fields/:resource/manage/:id' => 'has_fields/manage/fields#update', :as => :update_fields, :via => :put
  match '/:scope/:scope_id/fields/:resource/manage/:id' => 'has_fields/manage/fields#show', :as => :manage_fields, :via => :get
  match '/:resource/:id/fields/edit' => 'HasFields/fields#edit', :as => :edit_fields, :via => :get
  match '/:resource/:id/fields' => 'has_fields/fields#index', :as => :fields, :via => :get
  match '/:resource/:id/fields' => 'has_fields/fields#update', :as => :update_fields, :via => :put
end
