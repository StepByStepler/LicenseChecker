Rails.application.routes.draw do
  get 'licenses/add'
  get 'licenses/versions'
  get 'licenses/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'licenses#index'
end
