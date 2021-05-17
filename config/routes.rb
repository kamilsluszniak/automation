# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      devise_for  :users, singular: :user,
                          path: '',
                          path_names: {
                            sign_in: 'login',
                            sign_out: 'logout',
                            registration: 'signup'
                          },
                          controllers: {
                            sessions: 'api/v1/sessions',
                            registrations: 'api/v1/registrations'
                          }
      resources :devices

      resources :measurements, only: [:create]
      match 'measurements/show' => 'measurements#show', :via => :get
      resources :charts, only: :show
    end
  end
  get :ping, to: 'healthchecks#ping'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
