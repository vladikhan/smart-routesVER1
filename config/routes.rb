Rails.application.routes.draw do
  # Action Cable
  mount ActionCable.server => '/cable'

  # get 'home/index'
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
  resources :users, only: %i[index show edit update] do
    resource :follower, only: %i[create destroy], controller: 'follows'
  end

  # Email verification
  get 'email_verification', to: 'email_verifications#new'
  post 'email_verification', to: 'email_verifications#verify'
  post 'email_verification/resend', to: 'email_verifications#resend', as: 'email_verification_resend'

  # Logout confirmation
  # get 'logout_confirm', to: 'pages#logout_confirm'

  # Routes
  resources :routes do
    resources :comments, only: %i[create destroy]
    resources :reviews, only: %i[create edit update destroy]
    resources :likes, opacity: %i[create]
    resources :bookmarks, only: %i[create]
  end

  resources :likes, only: %i[create]
  delete 'likes', to: 'likes#destroy'

  resources :bookmarks, only: %i[create index]
  delete 'bookmarks', to: 'bookmarks#destroy'
  get 'me_bookmarks', to: 'bookmarks#index', as: :user_bookmarks

  # Locations
  resources :venues
  resources :cities, only: %i[index show]

  resources :dm_rooms, only: %i[index show create] do
    collection do
      get :sent
      get :received
    end
    member do
      post :mark_all_as_read
    end
    resources :dm_messages, only: %i[create destroy]
  end

  # Notification routes
  resources :notifications, only: [:index] do
    collection do
      get :unread_count
      patch :mark_all_as_read
    end
    member do
      patch :mark_as_read
    end
  end
end
