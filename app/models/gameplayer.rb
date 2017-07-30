class Gameplayer < ApplicationRecord
  validates :team, presence: true
  belongs_to :user
  belongs_to :game
end
