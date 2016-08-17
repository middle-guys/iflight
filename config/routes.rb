Rails.application.routes.draw do
  root 'homes#index'

  devise_for :users, :controllers => { registrations: 'users/registrations' }

  resources :routes do
    collection do
      get 'destination'
    end
  end

  resources :orders do
    member do
      get 'confirmation'
    end
  end

  match '/webhook' => 'homes#webhook', via: [:get, :post]
end
