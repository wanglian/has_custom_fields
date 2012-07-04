Rails.application.routes.draw do
  match '/:resource/:id/fields/edit' => 'HasFields/fields#edit', :as => :edit_fields, :via => :get
  match '/:resource/:id/fields' => 'has_fields/fields#index', :as => :fields, :via => :get
  match '/:resource/:id/fields' => 'has_fields/fields#update', :as => :update_fields, :via => :put
end
