Rails.application.routes.draw do
  # COMPANIES
  get 'companies', to: "companies#index"
  get 'companies/model/:ticker', to: "companies#model_show"
  get 'companies/:id', to: "companies#show"

  # USERS
  get 'users/:id', to: "users#show"
  post 'register', to: "authentications#register"
  post 'login', to: "authentications#login"

  # WATCHLIST
  get 'watchlists/:id', to: "watchlists#show"
  post 'watchlists/:id/delete/:company_id', to: "watchlists#delete_company_from_watchlist"

  # FEEDS
  post 'watchlistfeed', to: "newsfeeds#watchlist_feed"
  post 'filingfeed', to: "rssfilings#filing_feed"
  post 'historicalprices', to: "historicalprices#historical_prices"
  get 'companies/feed/:ticker', to: "newsfilingfeeds#feed"

  # EPS estimates from yahoo
  get 'companies/epsestimates/:ticker', to: "epsestimates#eps_estimates"
end
