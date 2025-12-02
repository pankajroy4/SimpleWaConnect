require "sidekiq/web"

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"
  # WEB USER AUTH (HTML UI)
  devise_for :users,
             controllers: {
               sessions: "users/sessions",
               registrations: "users/registrations",
               passwords: "users/passwords",
             }

  devise_scope :user do
    authenticated :user do
      root to: "welcome#index", as: :authenticated_root
    end

    unauthenticated do
      root to: "users/sessions#new", as: :unauthenticated_root
    end
  end

  # web messaging routes
  # messaging routes (add/merge)
  resources :customers, only: [:index, :show] do
    resources :messages, only: [:index, :create] do
      member do
        post :retry
      end
    end
  end

  resources :media, only: [:show]

  namespace :api do
    namespace :v1 do
      # API custom auth routes
      devise_scope :user do
        post "login", to: "sessions#create"
        delete "logout", to: "sessions#destroy"
        post "signup", to: "registrations#create"
      end

      resources :messages, only: [:create, :show]
    end
  end

  post "/webhook", to: "webhooks#receive"
  get "/webhook", to: "webhooks#verify"
end
