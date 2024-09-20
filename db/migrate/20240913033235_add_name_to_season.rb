class AddNameToSeason < ActiveRecord::Migration[7.2]
  def change
    add_column :seasons, :name, :string
  end
end
