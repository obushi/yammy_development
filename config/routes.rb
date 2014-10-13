Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root 'meal#daily'
  get '/history'      => 'meal#list'
  get '/search'       => 'meal#search'
  get '/ranking'      => 'meal#ranking'
  post '/upload'      => 'upload#new'

  get '/about'		    => 'static#about'
  get '/:date'        => 'meal#daily'

  namespace :api do
    namespace :v1 do
      get '/search'  => 'meal#search'
      get '/load'    => 'meal#load'
      get '/date'    => 'meal#date'
      get '/ranking' => 'meal#ranking'

      resources :votes, :only => [:show, :create, :destroy]
    end
  end
end