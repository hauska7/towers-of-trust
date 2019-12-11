Rails.application.routes.draw do
  devise_for :users, :controllers => { :registrations => 'users/registrations' }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "main#main"
  get '/about', to: 'main#about'
  get '/show_user/:user_id', to: 'main#show_user'
  post '/do_vote', to: 'main#do_vote'
  get '/do_dev_helper', to: 'main#do_dev_helper'
end
