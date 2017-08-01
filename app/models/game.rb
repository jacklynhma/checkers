class Game < ApplicationRecord
  validates :name, presence: true
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
    # default to empty array
    self.history_of_pieces ||= []
  end

# takes the difference between the from and to coordinate to determine
# the eatten piece. this only applies if 2x pieces were skipped
  # def eaten_piece?(from_coordinate, to_coordinate)
  #   if from_coordinate - to_coordinate =
  # end

  # row_index = current piece row, integer
  #column_index = current pice column, integer
  #checks if there is a neighboring opposing piece and if therei s a empty space diagonally
  # always return the destination or empty string or nil
  def can_eat_down?(row_index, column_index, eatingcolor)
    state = state_of_piece
    unless row_index > 5
      if column_index == 7
        if state[row_index + 1][column_index  - 1]&.first == eatingcolor && state[row_index + 2][column_index - 2] == nil
          return [row_index + 2, column_index - 2]
        end
      elsif column_index == 0
        if state[row_index + 1][column_index + 1]&.first == eatingcolor && state[row_index + 2][column_index + 2] == nil
          return [row_index + 2, column_index + 2]
        end
      else
        if state[row_index + 1][column_index  - 1]&.first == eatingcolor && state[row_index + 2][column_index - 2] == nil
          return [row_index + 2, column_index - 2]
        elsif state[row_index + 1][column_index + 1]&.first == eatingcolor && state[row_index + 2][column_index + 2] == nil
          return [row_index + 2, column_index + 2]
        else
          return nil
        end
      end
    end
  end

  def can_eat_up?(row_index, column_index, eatingcolor)
    state = state_of_piece
    unless row_index < 2
      if column_index == 0
        if state[row_index - 1][column_index + 1]&.first == eatingcolor && state[row_index - 2][column_index  + 2] == nil
          return [row_index - 2, column_index + 2]
        end
      elsif column_index == 7
        if state[row_index - 1][column_index - 1]&.first == eatingcolor && state[row_index - 2][column_index  - 2] == nil
          return [row_index - 2, column_index  - 2]
        end
      else
        if state[row_index - 1][column_index - 1]&.first == eatingcolor && state[row_index - 2][column_index  - 2] == nil

          return  [row_index - 2, column_index - 2]
        elsif state[row_index - 1][column_index + 1]&.first == eatingcolor && state[row_index - 2][column_index  + 2] == nil
          return [row_index - 2, column_index + 2]
        else
          return nil
        end
      end
    end
  end

  def pieces
    return state_of_piece
  end


  def required_moves(team)
    board = state_of_piece
    moves = []
    board.each_with_index do |row, row_index|
      row.each_with_index do |piece, column_index|

        if team == "red" && piece == "RK"
          next_move = can_eat_down?(row_index, column_index, "B")
        elsif team == "black" && piece == "BK"
          next_move = can_eat_up?(row_index, column_index, "R")
        end
        if team == "red" && piece&.first == "R"
          next_move = can_eat_up?(row_index, column_index, "B")
        elsif team == "black" && piece&.first == "B"
          next_move = can_eat_down?(row_index, column_index, "R")
        end
        unless next_move.blank?
          move = [row_index, column_index].concat(next_move)
          moves << move
        end
      end
    end
    return moves
  end

  def possible_moves(piece, row_index, column_index)
    possible_moves = []
    if  piece == "R" || piece == "RK" || piece == "BK" && state[row_index - 1][column_index  - 1] == nil
      possible_moves << [row_index - 1, column_index  - 1]
    elsif  piece == "R" || piece == "RK" || piece == "BK" && state[row_index - 1][column_index  + 1] == nil
      possible_moves << [row_index - 1, column_index  + 1]
    elsif  piece == "B" || piece == "RK" || piece == "BK"  && state[row_index + 1][column_index  + 1] == nil
      possible_moves << [row_index + 1, column_index  + 1]
    elsif  piece == "B" || piece == "RK" || piece == "BK"  && state[row_index + 1][column_index  - 1] == nil
      possible_moves << [row_index + 1, column_index  - 1]
    else
      return false
    end
    return possible_moves
  end

  def winner
    winner = "no one"
    board = state_of_piece
    board.each_with_index do |row, row_index|
      row.each_with_index do |piece, column_index|
      # possible_moves(piece, row_index, column_index) == []
        if piece&.first != "B" || piece == nil
          winner = "red"
        elsif piece&.first != "R" || piece == nil
          winner = "black"
        else
          return false
        end
      end
    end
    return winner
  end
end
