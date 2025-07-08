require 'rails_helper'

RSpec.describe "leaderboard/show_rank.html.erb", type: :view do
  it "displays user rank if present" do
    user = User.new(username: "player1", id: 1)
    leaderboard = Leaderboard.new(user: user, total_score: 100, rank: 1)
    assign(:user, user)
    assign(:leaderboard, leaderboard)
    render
    expect(rendered).to include("Your Rank")
    expect(rendered).to include("player1")
    expect(rendered).to include("Total Score: 100")
    expect(rendered).to include("Rank: 1")
  end

  it "displays error if user not found" do
    assign(:user, nil)
    assign(:leaderboard, nil)
    render
    expect(rendered).to include("User not found")
  end
end 