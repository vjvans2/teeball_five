# == Schema Information
#
# Table name: teams
#
#  id         :bigint           not null, primary key
#  city       :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Team < ApplicationRecord
  has_many :players, dependent: :destroy
  has_many :coaches, dependent: :destroy

  validates :city, presence: true
  validates :name, presence: true

  def full_team_name
    "#{city} #{name}"
  end
end
