class CreateFieldingPosition < ActiveRecord::Migration[7.2]
  def change
    create_table :fielding_positions do |t|
      t.string :name
      t.integer :hierarchy_rank

      t.timestamps
    end
  end
end
