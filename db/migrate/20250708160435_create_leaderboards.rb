class CreateLeaderboards < ActiveRecord::Migration[8.0]
  def change
    create_table :leaderboards do |t|
      t.references :user, null: false, foreign_key: true, unique: true
      t.integer :total_score
      t.integer :rank
    end
  end
end
