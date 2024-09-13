class RemovePlayerInningIdFromGamedayPlayers < ActiveRecord::Migration[7.2]
  def change
    remove_reference :gameday_players, :player_inning, index: true
  end
end
