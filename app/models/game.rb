# == Schema Information
#
# Table name: games
#
#  id            :bigint           not null, primary key
#  date          :date
#  is_home       :boolean
#  location      :string
#  opponent_name :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Game < ApplicationRecord
  # has_many :innings, optional: true
  has_many :coaches
  has_one :gameday_team
  has_many :player_innings, dependent: :destroy

  def full_team_name
    "#{city} #{name}"
  end
end
