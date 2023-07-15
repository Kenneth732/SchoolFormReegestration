Rails.application.routes.draw do
  resources :users, only: [:index, :show, :create, :update, :destroy]
  post "/login", to: "sessions#create"
  get "/me", to: "users#show"
  delete "/logout", to: "sessions#destroy"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
