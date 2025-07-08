require 'rails_helper'

RSpec.describe Leaderboard, type: :model do
  it { should belong_to(:user) }

  it "is valid with user and total_score" do
    user = User.create!(username: "player1")
    leaderboard = Leaderboard.new(user: user, total_score: 100)
    expect(leaderboard).to be_valid
  end

  it "is invalid without a user" do
    leaderboard = Leaderboard.new(user: nil, total_score: 100)
    expect(leaderboard).not_to be_valid
  end
end 