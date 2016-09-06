Rails.application.routes.draw do
  scope ":locale", locale: /en|vi/ do
    root 'homes#index'

  devise_for :users, controllers: { registrations: 'users/registrations', omniauth_callbacks: 'users/omniauth_callbacks'}

    get 'alerts/unsubscribe'
    patch 'alerts/unsubscribe'

    resources :alerts

    resources :about, only: [:index]

    resources :flights do
      collection do
        get 'share'
      end
    end

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
end
