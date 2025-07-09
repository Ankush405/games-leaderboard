class AddIndexesToLeaderboardAndGameSessions < ActiveRecord::Migration[7.0]
  def change
    add_index :leaderboards, :total_score, order: { total_score: :desc }
  end
end
