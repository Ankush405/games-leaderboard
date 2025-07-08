require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:game_sessions) }
  it { should have_one(:leaderboard) }

  it "is valid with a username" do
    user = User.new(username: "player1")
    expect(user).to be_valid
  end

  it "is invalid without a username" do
    user = User.new(username: nil)
    expect(user).not_to be_valid
  end

  it "destroys associated game_sessions when user is deleted" do
    user = User.create!(username: "player1")
    user.game_sessions.create!(score: 1000)
    expect { user.destroy }.to change { GameSession.count }.by(-1)
  end
end 
