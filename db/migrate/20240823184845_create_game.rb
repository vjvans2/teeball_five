class CreateGame < ActiveRecord::Migration[7.2]
  def change
    create_table :games do |t|
      t.string :location
      t.boolean :is_home
      t.string :opponent_name
      t.date :date

      t.timestamps
    end
  end
end
