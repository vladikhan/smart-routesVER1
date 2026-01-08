Rails.application.routes.draw do
  # Action Cable
  mount ActionCable.server => '/cable'

  get 'home/index'
  get '/health/check', to: proc { [200, {}, ['OK']] }

  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    sign_up: 'signup'
  }, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    confirmations: 'users/confirmations'
  }

  if Rails.env.development?
    # mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  root 'pages#home'

  # Home
  get 'search', to: 'home#search'

  # My Profile shortcuts
  get 'my_profile', to: 'users#my_profile'
  get 'profile', to: 'users#my_profile'
  get 'current_user', to: 'users#my_profile'
  get 'logout_confirm', to: 'pages#logout_confirm'

  # Users
  resources :users, only: %i[index show edit update]

  # Email verification
  get 'email_verification', to: 'email_verifications#new'
  post 'email_verification', to: 'email_verifications#verify'
  post 'email_verification/resend', to: 'email_verifications#resend', as: 'email_verification_resend'

  # Logout confirmation
  get 'logout_confirm', to: 'pages#logout_confirm'

  # Routes
  resources :routes
  resources :venues
  resources :cities, only: %i[index show]
  resources :users

  resources :dm_rooms, only: %i[index show create] do
    collection do
      get :sent
      get :received
    end
    member do
      post :mark_all_as_read
    end
    resources :dm_messages, only: [:create]
  end

  # Notification routes
  resources :notifications, only: [:index] do
    member do
      patch :mark_as_read
    end
    collection do
      patch :mark_all_as_read
      get :unread_count
    end
  end

  mount ActionCable.server => '/cable'
end
