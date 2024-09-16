class RemoveGamedayTeamsIdFromTeams < ActiveRecord::Migration[7.2]
  def change
    remove_reference :teams, :gameday_teams, index: true
  end
end
