class CreateSeason < ActiveRecord::Migration[7.2]
  def change
    create_table :seasons do |t|
      t.references :team, null: false, foreign_key: true
      t.references :games, null: false, foreign_key: true

      t.timestamps
    end
  end
end
