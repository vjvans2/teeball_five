class RemoveInningIdFromGames < ActiveRecord::Migration[7.2]
  def change
    remove_column :games, :inning_id, :bigint
  end
end
