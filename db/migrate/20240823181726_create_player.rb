class CreatePlayer < ActiveRecord::Migration[7.2]
  def change
    create_table :players do |t|
      t.string :first_name
      t.string :last_name
      t.integer :jersey_number

      t.timestamps
    end
  end
end
