class AddGameRefToPlayerInnings < ActiveRecord::Migration[7.2]
  def change
    add_reference :player_innings, :game, null: false, foreign_key: true
  end
end
