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
    if piece == "R" || piece == "RK" || piece == "BK" && column_index == 7
      if  piece == "R" || piece == "RK" || piece == "BK" && state_of_piece[row_index - 1][column_index  - 1] == nil
        return true
      end
    elsif piece == "R" || piece == "RK" || piece == "BK" && column_index == 0
      if  piece == "R" || piece == "RK" || piece == "BK" && state_of_piece[row_index - 1][column_index  + 1] == nil
        return true
      end
    elsif piece == "B" || piece == "RK" || piece == "BK" && column_index == 0
      if  piece == "B" || piece == "RK" || piece == "BK" && state_of_piece[row_index - 1][column_index  + 1] == nil
        return true
      end
    elsif piece == "B" || piece == "RK" || piece == "BK" && column_index == 7
      if  piece == "B" || piece == "RK" || piece == "BK" && state_of_piece[row_index - 1][column_index  - 1] == nil
        return true
      end
    else
      if  piece == "R" || piece == "RK" || piece == "BK" && state_of_piece[row_index - 1][column_index  - 1] == nil
        return true
      elsif  piece == "R" || piece == "RK" || piece == "BK" && state_of_piece[row_index - 1][column_index  + 1] == nil
        return true
      elsif  piece == "B" || piece == "RK" || piece == "BK"  && state_of_piece[row_index + 1][column_index  + 1] == nil
        return true
      elsif  piece == "B" || piece == "RK" || piece == "BK"  && state_of_piece[row_index + 1][column_index  - 1] == nil
        return true
      else
        return false
      end
    end
    return possible_moves
  end

  def team_missing_piece
    board = state_of_piece
    presence_of_team_black = []
    presence_of_team_red = []
    board.each_with_index do |row, row_index|
      if row.include?("B") || row.include?("BK")
        presence_of_team_black << true
      end
      if row.include?("R") || row.include?("RK")
        presence_of_team_red << true
      end
    end
    if !presence_of_team_black.include?(true)
      return "team black"
    elsif !presence_of_team_red.include?(true)
      return "team red"
    else
      return "everyone is present"
    end
  end
  #
  def winner

    winner = "no one"
    board = state_of_piece
    black_moves = []
    red_moves = []
    if team_missing_piece == "team black"
      return "Team Red Wins!"
    elsif team_missing_piece == "team red"
      return "Team Black Wins!"
    elsif team_missing_piece == "everyone is present"
      board.each_with_index do |row, row_index|
        row.each_with_index do |piece, column_index|
          if piece != nil && piece&.first == "B"
              black_moves << [possible_moves(piece, row_index, column_index), piece]
          end
          if piece != nil && piece&.first == "R"
            red_moves = [] << [possible_moves(piece, row_index, column_index), piece]
          end
        end
      end

      black_moves = black_moves.select { |move| move[0] == true}
      if !black_moves.nil?
        winner = "Team Red Wins!"
      end
      red_moves = red_moves.select { |move| move[0] == true}
      if !red_moves.nil?
        winner = "Team Black Wins!"
      end
    end
    return winner
  end
end
