Rails.application.routes.draw do
  get 'hello_world', to: 'hello_world#index'
  # Redirect www to non-www.
  if ENV['CANONICAL_HOST']
    constraints(host: Regexp.new("^(?!#{Regexp.escape(ENV['CANONICAL_HOST'])})")) do
      match '/(*path)' => redirect { |params, req| "https://#{ENV['CANONICAL_HOST']}/#{params[:path]}" },  via: [ :get, :post, :put, :delete ]
    end
  end

  root 'home#index'

  get '/about', to: 'home#about', as: 'about'

  get '/guidelines', to: 'appointments#guidelines', as: 'guidelines'

  get '/data/appointments',   to: 'data#appointments'
  get '/data/users',      to: 'data#users'
  get '/data/volunteers', to: 'data#volunteers'

  # get '/reports', to: "reports#index"

  get '/admin' => 'reports#index'
  # get '/admin/edit' => 'admin#edit_site', as: 'edit_site'
  # post '/admin/edit' => 'admin#edit_site'

  devise_for :users, controllers: { registrations: 'users/registrations' }
  devise_scope :user do
    get '/users/p/:page' => 'users/registrations#index', as: 'users_with_pagination'
    get 'users', to: 'users/registrations#index', as: 'volunteers'
    get 'users/:id', to: 'users/registrations#show', as: 'profile'
  end

  get '/appointments/p/:page' => 'appointments#index', as: 'appointments_with_pagination'

  delete '/images/:resource_name/:resource_id', to: 'images#destroy'

  resources :appointments do
    collection do
      get :volunteered
      get :own
    end

    member do
      post :toggle_volunteer
      post :completed_volunteer
      get :volunteers
    end
  end

  resources :offers

  resources :success_stories

  scope 'admin' do
    post :delete_user, to: 'admin#delete_user', as: 'delete_user'
    post :toggle_highlight, to: 'admin#toggle_highlight', as: 'toggle_appointment_highlight'
  end


  get '/:category_slug(/p/:page)', to: 'appointments#index', action: :index
  # get '/:location_slug(/p/:page)', to: 'appointments#index', action: :index


end
