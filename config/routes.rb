Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "songs#index"

  resources :songs, only: [ :index, :show, :destroy ] do
    member do
      get :analyze
      post :regenerate
    end
  end

  resources :song_parts, only: [] do
    resources :practice_sessions, only: [ :create, :show ] do
      resources :attempts, only: [ :create ]
    end
  end

  resources :practice_sessions, only: [ :index ] do
    member { patch :complete }
  end

  get "/dashboard", to: "dashboard#index", as: :dashboard
  get "/midi_setup", to: "midi_setup#show", as: :midi_setup
end
