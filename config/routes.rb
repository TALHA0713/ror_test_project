Rails.application.routes.draw do
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
    resources :tickets
  end

  resources :tickets do
    resources :comments
    resources :attachments
  end

  resources :comments do
    resources :attachments
  end
end
