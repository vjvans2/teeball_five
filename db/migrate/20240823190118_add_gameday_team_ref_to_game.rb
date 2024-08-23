class AddGamedayTeamRefToGame < ActiveRecord::Migration[7.2]
  def change
    add_reference :games, :gameday_team, null: false, foreign_key: true
  end
end
