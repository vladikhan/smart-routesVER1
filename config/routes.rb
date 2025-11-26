Rails.application.routes.draw do
  get 'home/index'
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    sign_up: 'signup'
  }, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
  
  root "pages#home"

  #Home 
  get 'search', to: 'home#search'
  
  # My Profile shortcuts
  get 'my_profile', to: 'users#my_profile'
  get 'profile', to: 'users#my_profile'
  get 'current_user', to: 'users#my_profile'
  
  # Users
  resources :users, only: [:index, :show, :edit, :update]
  
  # Email verification
  get 'email_verification', to: 'email_verifications#new'
  post 'email_verification', to: 'email_verifications#verify'
  post 'email_verification/resend', to: 'email_verifications#resend', as: 'email_verification_resend'
  
  # Logout confirmation
  get 'logout_confirm', to: 'pages#logout_confirm'
  
  # Routes
  resources :routes
  resources :venues, only: [:index, :show]
  resources :cities, only: [:index, :show]
end