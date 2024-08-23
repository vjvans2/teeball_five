class AddInningRefToGames < ActiveRecord::Migration[7.2]
  def change
    add_reference :games, :inning, null: false, foreign_key: true
  end
end
