Rails.application.routes.draw do
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    sign_up: 'signup'
  }, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  
  root "pages#home"

  #Email verification routes
  get 'email_verification', to: 'email_verifications#new'
  post 'email_verification', to: 'email_verifications#verify'
  post 'email_verification/resend', to: 'email_verifications#resend'

  # Logout confirmation
  get 'logout_confirm', to: 'pages#logout_confirm'
  
  # Routes
  resources :routes
  resources :venues, only: [:index, :show]
  resources :cities, only: [:index, :show]

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
