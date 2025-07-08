require 'rails_helper'

RSpec.describe "leaderboard/index.html.erb", type: :view do
  it "displays the leaderboard table" do
    assign(:top_players, [])
    render
    expect(rendered).to include("Leaderboard - Top 10 Players")
    expect(rendered).to include("Rank")
    expect(rendered).to include("Username")
    expect(rendered).to include("Total Score")
  end
end 