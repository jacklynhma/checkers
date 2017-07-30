class Game < ApplicationRecord
  validates :name, presence: true
  validates :history_of_pieces, presence: true
  validates :state_of_piece, presence: true

  has_many :gameplayers
  has_many :users, through: :gameplayers
  before_validation :setup_game, on: :create

  def after_initialize
    setup_game
  end

  def playing?(user)
    user_ids.include?(user.id)
  end

  def setup_game
    self.state_of_piece = [
    [nil, "B", nil, "B", nil, "B", nil, "B"],
    ["B", nil, "B", nil, "B", nil , "B", nil],
    [nil, "B", nil, "B", nil, "B", nil, "B"],
    [nil, nil, nil, nil, nil, nil, nil, nil],
    [nil, nil, nil, nil, nil, nil, nil, nil],
    ["R", nil, "R", nil, "R", nil, "R", nil],
    [nil, "R", nil, "R", nil, "R", nil, "R"],
    ["R", nil, "R", nil, "R", nil, "R", nil]
  ] if state_of_piece.nil? || state_of_piece === ""
  end

  def pieces
    return state_of_piece
  end
end
