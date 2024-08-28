class AddPlayerInningRefToGamedayPlayer < ActiveRecord::Migration[7.2]
  def change
    add_reference :gameday_players, :player_innings, null: true, foreign_key: true
  end
end
