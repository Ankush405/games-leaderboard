require 'rails_helper'

RSpec.describe GameSession, type: :model do
  it { should belong_to(:user) }

  it "is valid with user, score, and game_mode" do
    user = User.create!(username: "player1")
    session = GameSession.new(user: user, score: 100, game_mode: "classic")
    expect(session).to be_valid
  end

  it "is invalid without a user" do
    session = GameSession.new(user: nil, score: 100, game_mode: "classic")
    expect(session).not_to be_valid
  end
end 