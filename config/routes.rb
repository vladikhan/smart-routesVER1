Rails.application.routes.draw do
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    sign_up: 'signup'
  }
  
  root "pages#home"
  
  # Custom logout confirmation page
  get 'logout_confirm', to: 'pages#logout_confirm'
  
  # Routes
  resources :routes
  resources :venues, only: [:index, :show]
  resources :cities, only: [:index, :show]
end
