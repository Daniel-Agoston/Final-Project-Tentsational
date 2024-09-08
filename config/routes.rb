Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  get '/dashboard', to: 'dashboard#index'
  resources :items, only: [:index, :show, :new, :create, :destroy] do
    resources :bookings, only: [:new, :create]
    resources :reviews, only: [:new, :create]
  end

  resources :bookings, only: [:index, :destroy] # destroy route for bookings

  get "up" => "rails/health#show", as: :rails_health_check

   # Catch all route for non-existing paths
  match '*path', to: 'application#not_found', via: :all
end
