class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :username
      t.timestamp :join_date
    end
    add_index :users, :username, unique: true
  end
end
