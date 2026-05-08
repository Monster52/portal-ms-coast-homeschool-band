Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }

  resource  :profile, only: %i[show edit update]
  resources :family_connections, only: %i[create destroy]
  resources :announcements do
    resources :comments, only: %i[create destroy]
  end

  resources :conversations, only: %i[index show new create] do
    resources :messages, only: %i[create]
  end

  namespace :admin do
    resources :users, only: %i[index edit update destroy]
  end

  root "announcements#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
