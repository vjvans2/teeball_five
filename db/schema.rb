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

ActiveRecord::Schema[7.2].define(version: 2024_10_08_173515) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "coaches", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.bigint "associated_player_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "team_id", null: false
    t.boolean "is_head_coach"
    t.index ["associated_player_id"], name: "index_coaches_on_associated_player_id"
    t.index ["team_id"], name: "index_coaches_on_team_id"
  end

  create_table "fielding_positions", force: :cascade do |t|
    t.string "name"
    t.integer "hierarchy_rank"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gameday_players", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.boolean "is_present"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "gameday_team_id", null: false
    t.index ["gameday_team_id"], name: "index_gameday_players_on_gameday_team_id"
    t.index ["player_id"], name: "index_gameday_players_on_player_id"
  end

  create_table "gameday_teams", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "team_id", null: false
    t.index ["game_id"], name: "index_gameday_teams_on_game_id"
    t.index ["team_id"], name: "index_gameday_teams_on_team_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "location"
    t.boolean "is_home"
    t.string "opponent_name"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "season_id"
    t.index ["season_id"], name: "index_games_on_season_id"
  end

  create_table "innings", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.integer "inning_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "inning_number"], name: "index_innings_on_game_id_and_inning_number", unique: true
    t.index ["game_id"], name: "index_innings_on_game_id"
  end

  create_table "player_innings", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.bigint "inning_id", null: false
    t.bigint "fielding_position_id"
    t.integer "batting_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "game_id", null: false
    t.index ["fielding_position_id"], name: "index_player_innings_on_fielding_position_id"
    t.index ["game_id"], name: "index_player_innings_on_game_id"
    t.index ["inning_id"], name: "index_player_innings_on_inning_id"
    t.index ["player_id"], name: "index_player_innings_on_player_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.integer "jersey_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "team_id", null: false
    t.bigint "leadoffs", default: 0, null: false
    t.bigint "homeruns", default: 0, null: false
    t.bigint "postgame_cheer", default: 0, null: false
    t.bigint "direct_out", default: 0, null: false
    t.bigint "assist_out", default: 0, null: false
    t.bigint "sat_out", default: 0, null: false
    t.index ["team_id"], name: "index_players_on_team_id"
  end

  create_table "seasons", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["team_id"], name: "index_seasons_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.string "city"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "coaches", "players", column: "associated_player_id"
  add_foreign_key "coaches", "teams"
  add_foreign_key "gameday_players", "gameday_teams"
  add_foreign_key "gameday_players", "players"
  add_foreign_key "gameday_teams", "games"
  add_foreign_key "gameday_teams", "teams"
  add_foreign_key "games", "seasons"
  add_foreign_key "innings", "games"
  add_foreign_key "player_innings", "fielding_positions"
  add_foreign_key "player_innings", "games"
  add_foreign_key "player_innings", "innings"
  add_foreign_key "player_innings", "players"
  add_foreign_key "players", "teams"
  add_foreign_key "seasons", "teams"
end
