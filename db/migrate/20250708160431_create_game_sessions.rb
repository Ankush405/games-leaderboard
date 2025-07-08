class CreateGameSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :game_sessions do |t|
      t.references :user, null: false, foreign_key: true, unique: true
      t.integer :score
      t.string :game_mode
      t.timestamp :timestamp
    end
  end
end
