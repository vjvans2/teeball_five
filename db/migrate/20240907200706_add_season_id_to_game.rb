class AddSeasonIdToGame < ActiveRecord::Migration[7.2]
  def change
    add_reference :games, :season, null: false, foreign_key: true
  end
end