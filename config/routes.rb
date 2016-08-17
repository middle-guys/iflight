Rails.application.routes.draw do
  root 'homes#index'
  devise_for :users, :controllers => { registrations: 'users/registrations'}
  get 'alerts/unsubscribe'
  patch 'alerts/unsubscribe'
  get 'flights/index'
  resources :alerts
  resources :routes do
    collection do
      get 'destination'
    end
  end

  match '/webhook' => 'homes#webhook', via: [:get, :post]
end
