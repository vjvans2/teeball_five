class RemovePlayerInningsIdFromGamedayPlayers < ActiveRecord::Migration[7.2]
  def change
    remove_column :gameday_players, :player_innings_id, :bigint
  end
end
