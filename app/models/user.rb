class User < ApplicationRecord
  validates :username, presence: true

  # Associations
  has_many :game_sessions, dependent: :destroy
  has_one :leaderboard, dependent: :destroy
end
