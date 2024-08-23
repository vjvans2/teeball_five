class AddTeamRefToPlayers < ActiveRecord::Migration[7.2]
  def change
    add_reference :players, :team, null: false, foreign_key: true
  end
end
