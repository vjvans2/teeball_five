class RemoveGamedayPlayersIdFromGamedayTeam < ActiveRecord::Migration[7.2]
  def change
    remove_column :gameday_teams, :gameday_players_id, :bigint
  end
end
