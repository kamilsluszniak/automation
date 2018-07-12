Rails.application.routes.draw do

  devise_for :devices
  devise_for :users
  get :new_session, to: 'device_sessions#new_session'
  resources :devices

  resources :reports, only: [:create, :show]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
