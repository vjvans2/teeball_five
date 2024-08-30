class RemoveGamedayTeamsIdFromGamedayPlayers < ActiveRecord::Migration[7.2]
  def change
    remove_column :gameday_players, :gameday_teams_id, :bigint
  end
end
