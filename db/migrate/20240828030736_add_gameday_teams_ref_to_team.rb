class AddGamedayTeamsRefToTeam < ActiveRecord::Migration[7.2]
  def change
    add_reference :teams, :gameday_teams, null: true, foreign_key: true
  end
end
