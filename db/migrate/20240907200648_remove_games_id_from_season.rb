class RemoveGamesIdFromSeason < ActiveRecord::Migration[7.2]
  def change
    remove_column :seasons, :games_id
  end
end
