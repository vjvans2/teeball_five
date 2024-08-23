class CreateCoach < ActiveRecord::Migration[7.2]
  def change
    create_table :coaches do |t|
      t.string :first_name
      t.string :last_name
      t.references :associated_player, null: false, foreign_key: { to_table: :players }

      t.timestamps
    end
  end
end
