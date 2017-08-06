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

  def not_your_turn(team, turn)
    if team == "black" && (turn % 2 != 1)
      return true
    elsif  team == "red" && (turn % 2 != 0)
      return true
    end
  end

  def not_your_piece(team, piece)
    !(team == "black" && piece&.first == "B") && !(team == "red" && piece&.first == "R")
  end

  def off_the_board(to_row, to_column)
    if !((to_row <= 7) && (to_row >= 0))
    elsif !((to_column <= 7) && (to_column >= 0))
    end
  end

  def piece_must_moved(team, from_coordinate, to_coordinate)
    if required_moves(team) != [] && !required_moves(team).include?(from_coordinate + to_coordinate)
      return true
    end
  end

  def valid_R_move(from_column, to_column, from_row, to_row)
    ((from_column + 1 == to_column) || (from_column - 1 == to_column)) && (from_row - 1 == to_row)
  end

  def valid_B_move(from_column, to_column, from_row, to_row)
    ((from_column + 1 == to_column) || (from_column - 1 == to_column)) && (from_row + 1 == to_row)
  end

# checks the teams of the players
# returns an array of both teams
  def team_players
    black_team_players = []
    red_team_players = []
    array_of_teams = []
    self.gameplayers.each do |game|
      if game.team == "black"
        black_team_players << game.user.first_name
      elsif game.team == "red"
        red_team_players << game.user.first_name
      end
    end
    array_of_teams << black_team_players
    array_of_teams << red_team_players
     return array_of_teams
  end

  def validates_move( piece, team, from_column, to_column, from_row, to_row)
    unless state_of_piece[to_row][to_column] != nil
      if piece == "RK" || piece == "BK"
        valid_R_move(from_column, to_column, from_row, to_row) || valid_B_move(from_column, to_column, from_row, to_row)
      elsif team == "red"
        if piece == "R"
          valid_R_move(from_column, to_column, from_row, to_row)
        end
      elsif team == "black"
        if piece == "B"
          valid_B_move(from_column, to_column, from_row, to_row)
        end
      end
    end
  end

# the piece that is jumped is assigned nil
  def a_piece_jumped(team, from_row, to_row, from_column, to_column)
    if required_moves(team) != []
      state_of_piece[(from_row + to_row)/2][(from_column + to_column)/2] = nil
    end
  end

  def steps_to_do_if_no_error_messages(from_row, from_column, to_row, to_column, from_coordinate, to_coordinate, piece, team)
    #if a piece is eatten, the piece should be removed from the board
    a_piece_jumped(team, from_row, to_row, from_column, to_column)
    #moved piece is no longer at the from coordinate
    state_of_piece[from_row][from_column] = nil
    #that moved piece is now at the to coordinate
    state_of_piece[to_row][to_column] = piece
    history_of_pieces << [from: from_coordinate, to: to_coordinate]
    second_jump(team, to_row, from_row, to_coordinate)
    becoming_king(piece, to_row, to_column)
  end

  def error_message(from_row, from_column, team, piece, to_row, to_column, from_coordinate, to_coordinate)
    if not_your_turn(team, turn)
      "It is not your turn!"
    # Does the piece you want to move exist?
    elsif piece.nil?
      "That piece does not exist"
    # is it the player's piece?
    elsif not_your_piece(team, piece)
      "This is not your piece"
      # make the piece move on the board
      # the move needs to within the bounds of the board
    elsif off_the_board(to_row, to_column)
      "You are off the board"
      # must eat
    elsif piece_must_moved(team, from_coordinate, to_coordinate)
      "There is another piece you MUST move"
      # needs to be a legal move
      # if there is a piece next to you, you MUST eat it
    elsif !required_moves(team).include?(from_coordinate + to_coordinate) && !validates_move(piece, team, from_column, to_column, from_row, to_row)
      "That is not a legal move"
    end
  end

  # row_index = current piece row, integer
  # column_index = current pice column, integer
  # checks if there is a neighboring opposing piece and if therei s a empty space diagonally
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

# pass in the team and optional from coordinate to see if there is a required move w/ this starting from coordinate
# it will return an array of required moves
  def required_moves(team, from_coordinate = nil)
    board = state_of_piece
    moves = []
    board.each_with_index do |row, row_index|
      row.each_with_index do |piece, column_index|

        if team == "red" && piece == "RK"
          next_move = can_eat_down?(row_index, column_index, "B") || can_eat_up?(row_index, column_index, "B")
        elsif team == "black" && piece == "BK"
          next_move = can_eat_up?(row_index, column_index, "R") || can_eat_down?(row_index, column_index, "R")
        elsif team == "red" && piece == "R"
          next_move = can_eat_up?(row_index, column_index, "B")
        elsif team == "black" && piece == "B"
          next_move = can_eat_down?(row_index, column_index, "R")
        end
        unless next_move.blank?
          move = [row_index, column_index].concat(next_move)
          if from_coordinate != nil && from_coordinate == [row_index, column_index]
            moves << move
          elsif from_coordinate == nil
            moves << move
          end
        end
      end
    end
    return moves
  end

  def possible_moves(piece, row_index, column_index)
    unless (row_index > 6 && piece == "B") || (row_index < 1 && piece == "R")
      if (piece == "R" || piece == "RK" || piece == "BK") && column_index == 7
        if (piece == "R" || piece == "RK" || piece == "BK") && state_of_piece[row_index - 1][column_index  - 1] == nil
          return true
        end
      elsif (piece == "R" || piece == "RK" || piece == "BK") && column_index == 0
        if (piece == "R" || piece == "RK" || piece == "BK") && state_of_piece[row_index - 1][column_index  + 1] == nil
          return true
        end
      elsif (piece == "B" || piece == "RK" || piece == "BK" )&& column_index == 0
        if (piece == "B" || piece == "RK" || piece == "BK") && state_of_piece[row_index - 1][column_index  + 1] == nil
          return true
        end
      elsif (piece == "B" || piece == "RK" || piece == "BK" )&& column_index == 7
        if (piece == "B" || piece == "RK" || piece == "BK") && state_of_piece[row_index - 1][column_index  - 1] == nil
          return true
        end
      else
        if (piece == "R" || piece == "RK" || piece == "BK") && state_of_piece[row_index - 1][column_index  - 1] == nil
          return true
        elsif (piece == "R" || piece == "RK" || piece == "BK") && state_of_piece[row_index - 1][column_index  + 1] == nil
          return true
        elsif (piece == "B" || piece == "RK" || piece == "BK") && state_of_piece[row_index + 1][column_index  + 1] == nil
          return true
        elsif (piece == "B" || piece == "RK" || piece == "BK") && state_of_piece[row_index + 1][column_index  - 1] == nil
          return true
        else
          return false
        end
      end
    end
  end
  # if a piece reaches the end of opoosing board, it will be kinged
  # renaming a piece king
  def becoming_king(piece, to_row, to_column)
    if piece == "B" && to_row == 7
      self.state_of_piece[to_row][to_column] = "BK"
    elsif piece == "R" && to_row == 0
      self.state_of_piece[to_row][to_column] = "RK"
    end
  end

  # returns a message if a piece can job again
  def second_jump(team, to_row, from_row, to_coordinate)
    if team == "black" && (to_row - from_row == 2 || to_row - from_row == -2) && self.required_moves(team, to_coordinate).length > 0
      "you can jump again!"
    elsif team == "black"
      self.turn += 1
    elsif team == "red" &&  (to_row - from_row == 2 || to_row - from_row == -2) && self.required_moves(team, to_coordinate).length > 0
      "you can jump again!"
    elsif team == "red"
      self.turn += 1
    end
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
            red_moves << [possible_moves(piece, row_index, column_index), piece]
          end
        end
      end

      black_moves = black_moves.select { |move| move[0] == true}
      if black_moves.blank?
        winner = "Team Red Wins!"
      end
      red_moves = red_moves.select { |move| move[0] == true}
      if red_moves.blank?
        winner = "Team Black Wins!"
      end
    end
    return winner
  end
end
