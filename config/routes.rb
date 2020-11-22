Rails.application.routes.draw do
  resources :games, only: [:index, :create, :edit, :new] do
    member do
      post :join
      post :resign
    end
  end
  # static pages is react

  devise_for :users
  resources :users, only: [:index, :show, :destroy]
  root 'pages#home'
  get '/games/:id', to: 'static_pages#index'
  get '/games/:game_id/comments', to: 'static_pages#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # get '/games', to: 'static_pages#index'
  namespace :api do
    namespace :v1 do
      resources :games, only: [:show, :update, :edit] do
        member do
          get :history
        end
        resources :comments, only: [:index, :create]
      end
    end
  end
end
