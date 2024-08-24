class AddTeamRefToGamedayTeam < ActiveRecord::Migration[7.2]
  def change
    add_reference :gameday_teams, :team, null: false, foreign_key: true
  end
end
