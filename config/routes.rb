Rails.application.routes.draw do
  devise_for :users, :controllers => { :registrations => 'users/registrations' }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "main#main"
  get '/about', to: 'main#about'
  get '/new_group', to: 'main#new_group'
  get '/show_user/:user_id', to: 'main#show_user'
  get '/show_group/:group_id', to: 'main#show_group'
  post '/do_vote', to: 'main#do_vote'
  get '/do_dev_helper', to: 'main#do_dev_helper'
  get '/do_logout', to: 'users/registrations#destroy'
  post '/do_create/:mode', to: 'main#do_create'
  post '/do_destroy/:mode', to: 'main#do_destroy'
end
