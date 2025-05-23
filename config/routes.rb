Rails.application.routes.draw do
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
  resources :games, only: [ :new, :index, :show, :create, :update, :destroy ]
  resources :gameday_teams, only: [ :new, :create, :update ]
  resources :gameday_players, only: [ :new, :create, :update ]

  get "player_innings/edit", to: "player_innings#edit", as: "edit_game_player_innings"
  put "player_innings/update_multiple", to: "player_innings#update_multiple", as: "update_multiple_player_innings"
end
