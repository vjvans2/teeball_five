class AddGamedayTeamRefToGamedayPlayerAgain < ActiveRecord::Migration[7.2]
  def change
    add_reference :gameday_players, :gameday_team, null: false, foreign_key: true
  end
end
