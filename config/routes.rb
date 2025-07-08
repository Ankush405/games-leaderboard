Rails.application.routes.draw do
  get "leaderboard/index"
  get "leaderboard/submit_score"
  get "leaderboard/show_rank"
  namespace :api do
    post "leaderboard/submit", to: "leaderboard#submit"
    get "leaderboard/top", to: "leaderboard#top"
    get "leaderboard/rank/:user_id", to: "leaderboard#rank"
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
