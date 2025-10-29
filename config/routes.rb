Rails.application.routes.draw do
  root "pages#home"
  
  resources :routes
  resources :venues, only: [:index, :show]
  resources :cities, only: [:index, :show]
end
