class RenameGamedayPlayersPlayerInningsToSingular < ActiveRecord::Migration[7.2]
  def change
    rename_column :gameday_players, :player_innings_id, :player_inning_id
  end
end
