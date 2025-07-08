require 'rails_helper'

RSpec.describe LeaderboardController, type: :controller do
  render_views

  describe "GET #index" do
    it "renders the index template" do
      get :index
      expect(response).to render_template(:index)
      expect(response.body).to include("Leaderboard - Top 10 Players")
    end
  end

  describe "GET #show_rank" do
    let!(:user) { User.create!(username: "player1") }
    let!(:leaderboard) { Leaderboard.create!(user: user, total_score: 100, rank: 1) }

    it "renders the show_rank template with user info" do
      get :show_rank, params: { user_id: user.id }
      expect(response).to render_template(:show_rank)
      expect(response.body).to include("Your Rank")
      expect(response.body).to include(user.username)
    end

    it "renders the show_rank template with error if user not found" do
      get :show_rank, params: { user_id: 9999 }
      expect(response).to render_template(:show_rank)
      expect(response.body).to include("User not found")
    end
  end
end 