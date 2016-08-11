Rails.application.routes.draw do
  root 'homes#index'
  
  get 'flights/index'

  resources :routes do
    collection do
      get 'destination'
    end
  end

  devise_for :users
end
