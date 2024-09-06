class RemoveGamedayTeamsIdFromGamedayPlayers < ActiveRecord::Migration[7.2]
  def change
    if column_exists?(:gameday_players, :gameday_teams_id)
      remove_column :gameday_players, :gameday_teams_id
    else
      puts "Column gameday_team_id does not exist in gameday_players"
    end
  end
end
