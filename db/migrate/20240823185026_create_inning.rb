class CreateInning < ActiveRecord::Migration[7.2]
  def change
    create_table :innings do |t|
      t.references :game, null: false, foreign_key: true
      t.integer :inning_number

      t.timestamps
    end
  end
end
