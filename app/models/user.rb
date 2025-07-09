class User < ApplicationRecord
  validates :username, presence: true
  validates :score, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1_000_000 }

  # Associations
  has_many :game_sessions, dependent: :destroy
  has_one :leaderboard, dependent: :destroy
end
