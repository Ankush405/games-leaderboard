require 'rails_helper'

RSpec.describe "API::Leaderboard", type: :request do
  let!(:user) { User.create!(username: "testuser") }

  describe "POST /api/leaderboard/submit" do
    it "submits a score and updates leaderboard" do
      post "/api/leaderboard/submit", params: { user_id: user.id, score: 100 }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to eq("Score submitted successfully")
      expect(user.reload.leaderboard.total_score).to eq(100)
    end
  end

  describe "GET /api/leaderboard/top" do
    before do
      3.times { |i| User.create!(username: "user#{i}") }
      User.all.each { |u| Leaderboard.create!(user: u, total_score: rand(1..100)) }
    end
    it "returns top 10 players" do
      get "/api/leaderboard/top"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to be <= 10
    end
  end

  describe "GET /api/leaderboard/rank/:user_id" do
    before { Leaderboard.create!(user: user, total_score: 50, rank: 1) }
    it "returns the user's rank" do
      get "/api/leaderboard/rank/#{user.id}"
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["user_id"]).to eq(user.id)
      expect(body["rank"]).to eq(1)
    end
    it "returns error for missing user" do
      get "/api/leaderboard/rank/99999"
      expect(response).to have_http_status(:not_found)
    end
  end
end 