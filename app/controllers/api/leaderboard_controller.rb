module Api
  class LeaderboardController < ApplicationController
    include HmacRequestVerifier

    # POST /api/leaderboard/submit
    def submit
      user = User.find_by(id: params[:user_id])
      return render json: { error: 'User not found' }, status: :not_found unless user

      score = params[:score].to_i
      game_mode = params[:game_mode] || 'default'

      # Record game session
      GameSession.create!(user: user, score: score, game_mode: game_mode)

      # Update or create leaderboard entry atomically
      Leaderboard.transaction do
        # Handling phantom reads and writes
        # Lock the user record to prevent concurrent updates
        # This ensures that no two requests can update the same user's score at the same time
        user = User.lock.find(params[:user_id])
        leaderboard = Leaderboard.find_or_initialize_by(user: user)
        leaderboard.total_score = leaderboard.total_score.to_i + score
        leaderboard.save!
      end

      # Invalidate cache (no rank recalculation needed)
      Rails.cache.delete("leaderboard/top10")
      Rails.cache.delete("leaderboard/rank/#{user.id}")

      render json: { message: 'Score submitted successfully' }, status: :ok
    end

    # GET /api/leaderboard/top
    def top
      top_players = Rails.cache.fetch("leaderboard/top10", expires_in: 30.seconds) do
        Leaderboard
          .select("user_id, total_score, RANK() OVER (ORDER BY total_score DESC) as computed_rank")
          .joins(:user)
          .order("total_score DESC")
          .limit(10)
          .map do |entry|
            {
              user_id: entry.user_id,
              username: entry.user.username,
              total_score: entry.total_score,
              rank: entry.computed_rank
            }
          end
      end

      render json: top_players
    end

    # GET /api/leaderboard/rank/:user_id
    def rank
      user_id = params[:user_id]

      leaderboard = Rails.cache.fetch("leaderboard/rank/#{user_id}", expires_in: 30.seconds) do
        ranked = Leaderboard
                  .select("total_score, RANK() OVER (ORDER BY total_score DESC) as computed_rank")
                  .where(user_id: user_id)
                  .order("total_score DESC").first

        if ranked
          user = User.find_by(id: user_id)
          {
            user_id: user.id,
            username: user.username,
            total_score: ranked["total_score"],
            rank: ranked["computed_rank"]
          }
        end
      end

      if leaderboard
        render json: leaderboard
      else
        render json: { error: 'User not found in leaderboard' }, status: :not_found
      end
    end
  end
end

