require "test_helper"

class Api::LeaderboardControllerTest < ActionDispatch::IntegrationTest
  test "should get submit" do
    get api_leaderboard_submit_url
    assert_response :success
  end

  test "should get top" do
    get api_leaderboard_top_url
    assert_response :success
  end

  test "should get rank" do
    get api_leaderboard_rank_url
    assert_response :success
  end
end
