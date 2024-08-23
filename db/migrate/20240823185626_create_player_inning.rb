class CreatePlayerInning < ActiveRecord::Migration[7.2]
  def change
    create_table :player_innings do |t|
      t.references :player, null: false, foreign_key: true
      t.references :inning, null: false, foreign_key: true
      t.references :fielding_position, null: false, foreign_key: true
      t.integer :batting_order

      t.timestamps
    end
  end
end
