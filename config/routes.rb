Rails.application.routes.draw do
  get 'user/new'
  scope "(:locale)", locale: /en|vi/ do
  root 'static_pages#home'
  get "/help", to: "static_pages#help"
  get "/about", to: "static_pages#about"
  get "/contact", to: "static_pages#contact"
  get "/signup", to: "user#new"
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
  resources :user, except: :new
  end
end
