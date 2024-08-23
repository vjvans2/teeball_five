class CreateGamedayPlayers < ActiveRecord::Migration[7.2]
  def change
    create_table :gameday_players do |t|
      t.references :game, null: false, foreign_key: true
      t.references :player_innings, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.boolean :is_present

      t.timestamps
    end
  end
end
