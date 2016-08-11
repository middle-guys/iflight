Rails.application.routes.draw do
  root 'homes#index'

  get 'flights/index'

  resources :routes do
    collection do
      get 'destination'
    end
  end

  match '/webhook' => 'homes#webhook', via: [:get, :post]

  devise_for :users
end
