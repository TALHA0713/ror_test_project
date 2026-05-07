Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  get "sessions/new"
  get "/signup", to: "users#new"
  post "/signup", to: "users#create"
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
  root "home#index"
  resources :users
  resources :projects do
    member do
      delete "remove_member/:user_id", to: "projects#remove_member", as: :remove_member
    end
    resources :project_members
  end

  resources :tickets, only: [ :index, :new, :create, :show, :edit, :update ] do
    member do
      patch :update_status
    end
    resources :comments, only: :create
  end
  match "*path", to: "errors#not_found", via: :all
end
