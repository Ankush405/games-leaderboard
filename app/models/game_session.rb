class GameSession < ApplicationRecord
  validates :score, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1_000_000 }
  belongs_to :user
end
