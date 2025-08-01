# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_07_08_201554) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "game_sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "score"
    t.string "game_mode"
    t.datetime "timestamp", precision: nil
    t.index ["user_id"], name: "index_game_sessions_on_user_id"
  end

  create_table "leaderboards", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "total_score"
    t.integer "rank"
    t.index ["total_score"], name: "index_leaderboards_on_total_score", order: :desc
    t.index ["user_id"], name: "index_leaderboards_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.datetime "join_date", precision: nil
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "game_sessions", "users"
  add_foreign_key "leaderboards", "users"
end
