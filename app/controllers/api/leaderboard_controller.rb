
# module Api
#   class LeaderboardController < ApplicationController
#     # POST /api/leaderboard/submit
#     def submit
#       user = User.find_by(id: params[:user_id])
#       return render json: { error: 'User not found' }, status: :not_found unless user

#       score = params[:score].to_i
#       game_mode = params[:game_mode] || 'default'

#       # Create a new game session
#       GameSession.create!(user: user, score: score, game_mode: game_mode)

#       # Update or create leaderboard entry atomically
#       Leaderboard.transaction do
#         leaderboard = Leaderboard.lock.find_or_initialize_by(user: user)
#         leaderboard.total_score = leaderboard.total_score.to_i + score
#         leaderboard.save!
#       end

#       # Recalculate ranks
#       recalculate_ranks

#       # Invalidate cache
#       Rails.cache.delete("leaderboard/top10")
#       Rails.cache.delete("leaderboard/rank/#{user.id}")

#       render json: { message: 'Score submitted successfully' }, status: :ok
#     end

#     # GET /api/leaderboard/top
#     def top
#       top_players = Rails.cache.fetch("leaderboard/top10", expires_in: 30.seconds) do
#         Leaderboard.includes(:user).order(total_score: :desc).limit(10).map do |entry|
#           {
#             user_id: entry.user_id,
#             username: entry.user.username,
#             total_score: entry.total_score,
#             rank: entry.rank
#           }
#         end
#       end
#       render json: top_players
#     end

#     # GET /api/leaderboard/rank/:user_id
#     def rank
#       user_id = params[:user_id]
#       leaderboard = Rails.cache.fetch("leaderboard/rank/#{user_id}", expires_in: 30.seconds) do
#         entry = Leaderboard.includes(:user).find_by(user_id: user_id)
#         if entry
#           {
#             user_id: entry.user_id,
#             username: entry.user.username,
#             total_score: entry.total_score,
#             rank: entry.rank
#           }
#         end
#       end

#       if leaderboard
#         render json: leaderboard
#       else
#         render json: { error: 'User not found in leaderboard' }, status: :not_found
#       end
#     end

#     private

#     def recalculate_ranks
#       Leaderboard.order(total_score: :desc).each_with_index do |entry, idx|
#         entry.update(rank: idx + 1)
#       end
#     end
#   end
# end

module Api
  class LeaderboardController < ApplicationController
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
        leaderboard = Leaderboard.lock.find_or_initialize_by(user: user)
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
        subquery = <<~SQL
          SELECT user_id, total_score, RANK() OVER (ORDER BY total_score DESC) AS computed_rank
          FROM leaderboards
        SQL

        ranked = ActiveRecord::Base.connection.exec_query("SELECT * FROM (#{subquery}) AS ranked WHERE user_id = #{user_id.to_i}").first

        if ranked
          user = User.find_by(id: ranked["user_id"])
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

