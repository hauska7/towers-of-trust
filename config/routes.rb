Rails.application.routes.draw do
  devise_for :users, :controllers => { :registrations => 'users/registrations' }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "home#index"
  get '/home', to: 'home#home', as: 'home'
  get '/info', to: 'home#info', as: 'info'

  resources :cities, only: [:index, :new, :create, :edit, :update] do
    put :join, on: :member
  end
  resources :meetings, only: [:index, :show] do
    put :happened, on: :member
    put :didnt_happen, on: :member
  end
end
