class AddUniqueIndexToInnings < ActiveRecord::Migration[7.2]
  def change
    add_index :innings, [ :game_id, :inning_number ], unique: true
  end
end
