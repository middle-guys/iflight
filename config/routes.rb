Rails.application.routes.draw do
  root 'homes#index'

  devise_for :users, :controllers => { registrations: 'users/registrations' }

  get 'flights/index'

  resources :routes do
    collection do
      get 'destination'
    end
  end

  resources :orders

  match '/webhook' => 'homes#webhook', via: [:get, :post]
end
