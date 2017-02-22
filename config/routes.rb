Rails.application.routes.draw do

  get 'users/:id', to: "users#show"

  get 'companies/:id', to: "companies#show"

  # COMPANIES
  get 'companies', to: "companies#index"
  # USERS
  get 'users/:id', to: "users#show"

  get 'companies/model', to: "companies#model_show"

  post 'register', to: "authentications#register"
  post 'login', to: "authentications#login"

  # FEEDS
  post 'watchlistfeed', to: "newsfeeds#watchlist_feed"
  post 'filingfeed', to: "rssfilings#filing_feed"
  post 'historicalprices', to: "historicalprices#historical_prices"
end
