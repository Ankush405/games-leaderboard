require 'rails_helper'

RSpec.describe "Leaderboards", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/leaderboard/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show_rank" do
    it "returns http success" do
      get "/leaderboard/show_rank"
      expect(response).to have_http_status(:success)
    end
  end
end
