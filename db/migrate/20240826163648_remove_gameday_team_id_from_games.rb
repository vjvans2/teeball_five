class RemoveGamedayTeamIdFromGames < ActiveRecord::Migration[7.2]
  def change
    remove_column :games, :gameday_team_id, :bigint
  end
end
