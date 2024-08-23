class CreateGamedayTeam < ActiveRecord::Migration[7.2]
  def change
    create_table :gameday_teams do |t|
      t.references :game, null: false, foreign_key: true
      t.references :gameday_players, null: false, foreign_key: true

      t.timestamps
    end
  end
end
