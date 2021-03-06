class Game < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :state_of_piece, presence: true

  has_many :gameplayers
  has_many :comments
  has_many :users, through: :gameplayers
  before_validation :setup_game, on: :create

  def after_initialize
    setup_game
  end

  def playing?(user)
    user_ids.include?(user.id)
  end

  def starting_board
    [
    [nil, "B", nil, "B", nil, "B", nil, "B"],
    ["B", nil, "B", nil, "B", nil , "B", nil],
    [nil, "B", nil, "B", nil, "B", nil, "B"],
    [nil, nil, nil, nil, nil, nil, nil, nil],
    [nil, nil, nil, nil, nil, nil, nil, nil],
    ["R", nil, "R", nil, "R", nil, "R", nil],
    [nil, "R", nil, "R", nil, "R", nil, "R"],
    ["R", nil, "R", nil, "R", nil, "R", nil]
  ]
  end

  def setup_game
    self.state_of_piece = starting_board if state_of_piece.nil? ||
      state_of_piece === ""
    # default to empty array
    self.history_of_pieces ||= []
  end

  def assign_team(current_user)
    if red_team_count <  black_team_count
      gameplayers.create(user: current_user, team: "red")
    else
      gameplayers.create(user: current_user, team: "black")
    end
  end

  def red_team_count
    gameplayers.where(team: "red").count
  end

  def black_team_count
    gameplayers.where(team: "black").count
  end

  def not_your_turn(team, turn)
    if team == "black" && (turn % 2 != 1)
      return true
    elsif  team == "red" && (turn % 2 != 0)
      return true
    else
      return false
    end
  end

  # returns true if it is not your piece
  def not_your_piece(team, piece)
    !(team == "black" && piece&.first == "B") && !(team == "red" &&
    piece&.first == "R")
  end

  # returns true if piece is off the board
  def off_the_board(to_row, to_column)
   !((to_row <= 7) && (to_row >= 0)) || !((to_column <= 7) && (to_column >= 0))
  end

  # returns true if there is another piece you must move
  def piece_must_moved(team, from_coordinate, to_coordinate)
    if required_moves(team) != [] &&
      !required_moves(team).include?(from_coordinate + to_coordinate)
      return true
    else
      return false
    end
  end

  # will return true if R piece is a valid move
  def valid_R_move(from_row, from_column, to_row, to_column)
    ((from_column + 1 == to_column) || (from_column - 1 == to_column)) &&
    (from_row - 1 == to_row)
  end

  # will return true if B piece is a valid move
  def valid_B_move(from_row, from_column, to_row, to_column)
    ((from_column + 1 == to_column) || (from_column - 1 == to_column)) &&
    (from_row + 1 == to_row)
  end

# checks the teams of the players
# returns an array of both teams
  def team_players
    black_team_players = []
    red_team_players = []
    array_of_teams = []
    self.gameplayers.each do |game|
      if game.team == "black"
        black_team_players << game.user
      elsif game.team == "red"
        red_team_players << game.user
      end
    end
    array_of_teams << black_team_players
    array_of_teams << red_team_players
     return array_of_teams
  end

  #used when a user clicks the replay button
  # return state of piece as it irritates over the history of pieces
  # it stops once the index of the history of the piece is greater than
  # the turn
  def set_board(turn)
    i = 0
    self.state_of_piece = starting_board
    while i < turn.to_i
      coordinates = self.history_of_pieces[i]
      from_coordinate = [coordinates[0], coordinates[1]]
      to_coordinate = [coordinates[2], coordinates[3]]
      piece = self.state_of_piece[from_coordinate[0]][from_coordinate[1]]
      # updates pieces on borad
      move_piece(from_coordinate, to_coordinate, piece)
      i += 1
    end
    return self.state_of_piece
  end

  #returns true if the from_coordinate and the to coordinate are not illegal moves
  def validates_move(piece, team, from_coordinate, to_coordinate)
    unless state_of_piece[to_coordinate[0]][to_coordinate[1]] != nil
      if piece == "RK" || piece == "BK"
        valid_R_move(from_coordinate[0], from_coordinate[1], to_coordinate[0],
        to_coordinate[1]) || valid_B_move(from_coordinate[0], from_coordinate[1],
        to_coordinate[0], to_coordinate[1])
      elsif team == "red"
        if piece == "R"
          valid_R_move(from_coordinate[0], from_coordinate[1], to_coordinate[0],
          to_coordinate[1])
        end
      elsif team == "black"
        if piece == "B"
          valid_B_move(from_coordinate[0], from_coordinate[1], to_coordinate[0],
          to_coordinate[1])
        end
      end
    end
  end

  # the piece that is jumped is assigned nil
  def a_piece_jumped(from_row, to_row, from_column, to_column)
    if (from_row - to_row).abs == 2
      state_of_piece[(from_row + to_row)/2][(from_column + to_column)/2] = nil
    end
  end

  # if the move is valid, this method changes the pieces on the board
  # depending on what type of valid move it is
  def move_piece(from_coordinate, to_coordinate, piece)
    # if a piece is eatten, the piece should be removed from the board
    a_piece_jumped(from_coordinate[0], to_coordinate[0], from_coordinate[1], to_coordinate[1])
    # moved piece is no longer at the from coordinate
    state_of_piece[from_coordinate[0]][from_coordinate[1]] = nil
    # that moved piece is now at the to coordinate
    state_of_piece[to_coordinate[0]][to_coordinate[1]] = piece
    becoming_king(piece, to_coordinate[0], to_coordinate[1])
  end

  # updates after a successful move.
  # add to history and increment turn count if necessary
  def update_turn(from_coordinate, to_coordinate, team)
    history_of_pieces << [from_coordinate[0], from_coordinate[1], to_coordinate[0], to_coordinate[1]]
    unless second_jump(team, to_coordinate[0], from_coordinate[0], to_coordinate)
      self.turn += 1
    end
    save
  end

  # presents an error message on top of the board if there is an illegal move
  def error_message(team, piece, from_coordinate, to_coordinate)
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
    elsif off_the_board(to_coordinate[0], to_coordinate[1])
      "You are off the board"
      # must eat
    elsif piece_must_moved(team, from_coordinate, to_coordinate)
      "There is another piece you MUST move"
      # needs to be a legal move
      # if there is a piece next to you, you MUST eat it
    elsif illegal_move(team, from_coordinate, to_coordinate, piece)
      "That is not a legal move"
    end
  end

  def illegal_move(team, from_coordinate, to_coordinate, piece)
    !required_moves(team).include?(from_coordinate + to_coordinate) &&
      !validates_move(piece, team, from_coordinate, to_coordinate)
  end

  # row_index = current piece row, integer
  # column_index = current pice column, integer
  # checks if there is a neighboring opposing piece and if therei s a empty
  # space diagonally
  # always return the destination or empty string or nil
  def can_eat_down?(row_index, column_index, eatingcolor)
    state = state_of_piece
    if row_index + 2 <= 7
      if column_index == 7 && column_index == 6
        if state[row_index + 1][column_index  - 1]&.first == eatingcolor &&
          state[row_index + 2][column_index - 2] == nil
          # need to write a condition that it is on the board
          return [row_index + 2, column_index - 2]
        end
      elsif column_index == 0 && column_index == 1
        if state[row_index + 1][column_index + 1]&.first == eatingcolor &&
          state[row_index + 2][column_index + 2] == nil
          return [row_index + 2, column_index + 2]
        end
      else
        if state[row_index + 1][column_index  - 1]&.first == eatingcolor &&
          state[row_index + 2][column_index - 2] == nil
          return [row_index + 2, column_index - 2]
        elsif state[row_index + 1][column_index + 1]&.first == eatingcolor &&
          state[row_index + 2][column_index + 2] == nil
          return [row_index + 2, column_index + 2]
        else
          return nil
        end
      end
    end
  end

  # returns coordinates if there is a piece on the board that jump upward
  def can_eat_up?(row_index, column_index, eatingcolor)
    state = state_of_piece
    if row_index - 2 >= 0
      if column_index == 0 && column_index == 1
        if state[row_index - 1][column_index + 1]&.first == eatingcolor &&
          state[row_index - 2][column_index  + 2] == nil
          return [row_index - 2, column_index + 2]
        end
      elsif column_index == 7 && column_index == 6
        if state[row_index - 1][column_index - 1]&.first == eatingcolor &&
          state[row_index - 2][column_index  - 2] == nil
          return [row_index - 2, column_index  - 2]
        end
      else
        if state[row_index - 1][column_index - 1]&.first == eatingcolor &&
          state[row_index - 2][column_index  - 2] == nil
          return  [row_index - 2, column_index - 2]
        elsif state[row_index - 1][column_index + 1]&.first == eatingcolor &&
          state[row_index - 2][column_index  + 2] == nil
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

# pass in the team and optional from coordinate to see if there is a required
# move w/ this starting from coordinate
# it will return an array of required moves
  def required_moves(team, from_coordinate = nil)
    board = state_of_piece
    moves = []
    board.each_with_index do |row, row_index|
      row.each_with_index do |piece, column_index|
        if team == "red" && piece == "RK"
          next_move = can_eat_down?(row_index, column_index, "B") ||
          can_eat_up?(row_index, column_index, "B")
        elsif team == "black" && piece == "BK"
          next_move = can_eat_up?(row_index, column_index, "R") ||
          can_eat_down?(row_index, column_index, "R")
        elsif team == "red" && piece == "R"
          next_move = can_eat_up?(row_index, column_index, "B")
        elsif team == "black" && piece == "B"
          next_move = can_eat_down?(row_index, column_index, "R")
        end
        unless next_move.blank?
          # discard the move if it would take the piece off the board
          move = [row_index, column_index].concat(next_move)
          if off_the_board(next_move[0], next_move[1])
            # do nothing
          elsif from_coordinate != nil && from_coordinate == [row_index, column_index]
            moves << move
          elsif from_coordinate == nil
            moves << move
          end
        end
      end
    end
    return moves
  end

  # gives the possible moves a user can make based off the piece they clicked
  def calculate_possible_moves(piece, row_index, column_index)
    moves = []
    unless (row_index > 6 && piece == "B") || (row_index < 1 && piece == "R")
      if (piece == "R" || piece == "RK" || piece == "BK") && column_index == 7
        if (piece == "R" || piece == "RK" || piece == "BK") &&
          state_of_piece[row_index - 1][column_index  - 1] == nil
          moves << [row_index - 1, column_index  - 1]
        end
      elsif (piece == "R" || piece == "RK" || piece == "BK") && column_index == 0
        if (piece == "R" || piece == "RK" || piece == "BK") &&
          state_of_piece[row_index - 1][column_index  + 1] == nil
          moves << [row_index - 1, column_index  + 1]
        end
      elsif (piece == "B" || piece == "RK" || piece == "BK" )&& column_index == 0
        if (piece == "B" || piece == "RK" || piece == "BK") &&
          state_of_piece[row_index + 1][column_index  + 1] == nil
          moves << [row_index + 1, column_index  + 1]
        end
      elsif (piece == "B" || piece == "RK" || piece == "BK" )&& column_index == 7
        if (piece == "B" || piece == "RK" || piece == "BK") &&
          state_of_piece[row_index + 1][column_index  - 1] == nil
          moves << [row_index + 1, column_index  - 1]
        end
      end
      if (piece == "R" || piece == "RK" || piece == "BK") && row_index != 0 &&
        state_of_piece[row_index - 1][column_index  - 1] == nil
        moves << [row_index - 1, column_index  - 1]
      end
      if (piece == "R" || piece == "RK" || piece == "BK") && row_index != 0 &&
        state_of_piece[row_index - 1][column_index  + 1] == nil
        moves << [row_index - 1, column_index  + 1]
      end
      if (piece == "B" || piece == "RK" || piece == "BK") && row_index != 7 &&
        state_of_piece[row_index + 1][column_index  + 1] == nil
        moves << [row_index + 1, column_index  + 1]
      end
      if (piece == "B" || piece == "RK" || piece == "BK") && row_index != 7 &&
        state_of_piece[row_index + 1][column_index  - 1] == nil
        moves << [row_index + 1, column_index  - 1]
      end
    end
    return moves
  end

  # used to help determine if there is a winner given the condition that the opposing user
  # can no longer move
  # returns false if the opposing user has no possible moves
  def possible_moves(piece, row_index, column_index)
    unless (row_index > 6 && piece == "B") || (row_index < 1 && piece == "R")
      if (piece == "R" || piece == "RK" || piece == "BK") && column_index == 7
        if (piece == "R" || piece == "RK" || piece == "BK") &&
          state_of_piece[row_index - 1][column_index  - 1] == nil
          return true
        end
      elsif (piece == "R" || piece == "RK" || piece == "BK") && column_index == 0
        if (piece == "R" || piece == "RK" || piece == "BK") &&
          state_of_piece[row_index - 1][column_index  + 1] == nil
          return true
        end
      elsif (piece == "B" || piece == "RK" || piece == "BK" )&& column_index == 0
        if (piece == "B" || piece == "RK" || piece == "BK") &&
          state_of_piece[row_index - 1][column_index  + 1] == nil
          return true
        end
      elsif (piece == "B" || piece == "RK" || piece == "BK" )&& column_index == 7
        if (piece == "B" || piece == "RK" || piece == "BK") &&
          state_of_piece[row_index - 1][column_index  - 1] == nil
          return true
        end
      else
        if (piece == "R" || piece == "RK" || piece == "BK") &&
          state_of_piece[row_index - 1][column_index  - 1] == nil
          return true
        elsif (piece == "R" || piece == "RK" || piece == "BK") &&
          state_of_piece[row_index - 1][column_index  + 1] == nil
          return true
        elsif (piece == "B" || piece == "RK" || piece == "BK") &&
          state_of_piece[row_index + 1][column_index  + 1] == nil
          return true
        elsif (piece == "B" || piece == "RK" || piece == "BK") &&
          state_of_piece[row_index + 1][column_index  - 1] == nil
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

  # returns a message if a piece can jump again
  # else increments the turn number
  # @param team - the team of the player
  # @return [boolean] whether the player can jump again
  def second_jump(team, to_row, from_row, to_coordinate)
    if team == "black" && (to_row - from_row == 2 || to_row - from_row == -2) &&
      required_moves(team, to_coordinate).length > 0
      true
    elsif team == "red" &&  (to_row - from_row == 2 || to_row - from_row == -2) &&
      required_moves(team, to_coordinate).length > 0
      true
    else
      false
    end
  end

  # another factor if the user wins. if there are no longer any opposing pieces
  # on the board, then the other user wins.
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

  # returns the winner of the game if there are only one set of pieces on the board
  # returns winner if the opposing player does not have any more possible moves
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
