# frozen_string_literal: true

Rails.application.routes.draw do
  mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql' if Rails.env.development?
  post '/graphql', to: 'graphql#execute'
  devise_for  :users,
              path: '',
              path_names: {
                sign_in: 'login',
                sign_out: 'logout'
              },
              controllers: {
                sessions: 'sessions'
              }
  resources :devices

  get :device_settings, to: 'devices#device_settings'

  resources :reports, only: :create
  match 'reports/show' => 'reports#show', :via => :get
  resources :charts, only: :show
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
