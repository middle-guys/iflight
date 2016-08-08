Rails.application.routes.draw do
  root "homes#index"
  
  get 'flights/index'

  devise_for :users
end
