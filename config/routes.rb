require 'sidekiq/web'
require 'sidekiq/cron/web'

Sidekiq::Web.use ActionDispatch::Cookies
Sidekiq::Web.use ActionDispatch::Session::CookieStore, key: "_interslice_session"

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  Sidekiq::Web.use(Rack::Auth::Basic) do |username, password|
    username == ENV["SIDEKIQ_WEB_USERNAME"] &&
    password == ENV["SIDEKIQ_WEB_PASSWORD"]
  end
  mount Sidekiq::Web => "/sidekiq"

  defaults format: :json do
    post 'webhook/ping', to: 'webhook#ping'

    scope "posts" do
      get "/", to: "posts#index"
      get ":post_id", to: "posts#show"
    end

    root "home#index"
  end
end
