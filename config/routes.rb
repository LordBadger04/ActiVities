require 'google/apis/calendar_v3'

Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  # get "/redirect", to: "chats#redirect"
  # get "/callback", to: "chats#callback"
  get    "/auth/google_calendar/callback", to: "sessions#google_calendar"
  get    "/auth/failure",                  to: "sessions#google_failure"
  delete "/google_calendar",               to: "sessions#google_disconnect", as: :google_disconnect

  get '/404', to: 'errors#not_found'
  get '/500', to: 'errors#internal_server_error'

  resources :events, except: [ :destroy ] do
    collection do
      get :history
    end
    member do
      patch :cancel
      post :add_to_google
    end
    resources :event_memberships, only: [ :create, :update, :edit, :index ]
    resources :chats, only: [ :create ]
  end

  resources :chats, only: [ :index, :show ] do
    resources :messages, only: [ :create ]
  end

  resources :profiles, only: [ :show, :new, :create, :edit, :update ]

  match '*path', to: 'errors#not_found', via: :all
end
