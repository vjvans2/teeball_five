Rails.application.routes.draw do
  get "player_innings/post"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "home#homepage"
  resources :teams do
    resources :players do
      member do
        put "increment/:property", to: "players#increment", as: "increment"
        put "decrement/:property", to: "players#decrement", as: "decrement"
      end
    end
  end

  resources :players, except: [ :new, :create, :update ]
  resources :games, only: [ :index, :show ]
  resources :gameday_teams, only: [ :show ]
  resources :gameday_players, only: [ :show ]
end
