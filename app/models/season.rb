class Season < ApplicationRecord
  has_many :games
  has_one :team
end
