Rails.application.routes.draw do
  # static pages is react
  root "static_pages#index"
  get '/games/:id', to: 'static_pages#index'
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # get '/games', to: 'static_pages#index'
  namespace :api do
    namespace :v1 do
      resources :games
    end
  end
  resources :games do
    member do
      post :join
      post :resign
    end
  end
end
