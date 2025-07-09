class LeaderboardController < ApplicationController
  def index
    @top_players = Rails.cache.fetch("leaderboard/top10", expires_in: 30.seconds) do
        Leaderboard
          .select("user_id, total_score, RANK() OVER (ORDER BY total_score DESC) as computed_rank")
          .joins(:user)
          .order("total_score DESC")
          .limit(10)
          .map do |entry|
            {
              username: entry.user.username,
              total_score: entry.total_score,
              rank: entry.computed_rank
            }
          end
      end
  end

  def show_rank
    user_id = params[:user_id]
    @user = User.find_by(id: user_id)
    @leaderboard = Rails.cache.fetch("leaderboard/rank/#{user_id}", expires_in: 30.seconds) do
      ranked = Leaderboard
                  .select("total_score, RANK() OVER (ORDER BY total_score DESC) as computed_rank")
                  .where(user_id: user_id)
                  .order("total_score DESC").first

      if ranked
        {
          username: @user.username,
          total_score: ranked["total_score"],
          rank: ranked["computed_rank"]
        }
      end
    end
  end
end
