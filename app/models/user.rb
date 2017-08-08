class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  validates_presence_of :first_name
  has_many :gameplayers
  has_many :comments
  has_many :games, through: :gameplayers

  def admin?
   role == "admin"
  end

  def playing?(game)
    game_ids.include?(game.id)
  end

  def defining_team(game)
    if self.playing?(game)
      return self.gameplayers.find_by(game_id: game.id).team
    end
  end

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
