Rails.application.routes.draw do
  devise_for :users
  root "games#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # get '/games', to: 'static_pages#index'
  resources :games do
    member do
      post :join
      post :resign
    end
  end
end
