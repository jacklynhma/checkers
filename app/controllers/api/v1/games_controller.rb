class Api::V1::GamesController < ApplicationController
  skip_before_action :verify_authenticity_token
  def index
    render json: Game.all, adapter: :json
  end

  def show
    render json: Game.find(params[:id]), adapter: :json
  end
  def update
    @game = Game.find(params[:id])

    state = @game.state_of_piece

    # params[:coordinate][:from]
    # params[:coordinate][:to]

    # make sure a piece deletes from a board before you put a piece on the board
    message = ""

    # do stuff to the state of game, like moving the pieces
    # # delete the piece on the board
    # from_coordinate = JSON.parse(params[:coordinate][:from])
    # to_coordinate = JSON.parse(params[:coordinate][:to])
    # is it your turn


    from_coordinate = [params[:coordinates][0], params[:coordinates][1]]
    to_coordinate = [params[:coordinates][2], params[:coordinates][3]]
    to_column = params[:coordinates][3]
    from_column = params[:coordinates][1]
    from_row = params[:coordinates][0]
    to_row = params[:coordinates][2]
    validates_red_moves = ((from_column + 1) != to_column) && ((from_column - 1) != to_column) || ((from_row - 1) != to_row)
    validates_black_moves = ((from_column + 1) != to_column) && ((from_column - 1) != to_column) || ((from_row + 1) != to_row)
    piece = state[from_row][from_column]

    if current_user.gameplayers.find_by(game_id: @game.id).present?
      team = current_user.gameplayers.find_by(game_id: @game.id).team
    end
    if (!team == "black" && (turn % 2 == 1)) || (!team == "red" && (turn % 2 == 0))
      flash[:notice] = "It is not your turn!"
    # Does the piece you want to move exist?
    elsif piece.nil?
      flash[:notice] = "That piece does not exist"
    # is it the player's piece?
    elsif !(team == "black" && piece&.first == "B") && !(team == "red" && piece&.first == "R")
      flash[:notice] = "This is not your piece"
    # make the piece move on the board
    # the move needs to within the bounds of the board
    elsif !((to_row <= 7) && (to_row >= 0))
      flash[:notice] = "You are off the board"
    elsif !((to_column <= 7) && (to_column >= 0))
      flash[:notice] = "You are off the board"
    # must eat
    elsif @game.required_moves(team) != [] && !@game.required_moves(team).include?(from_coordinate + to_coordinate)
      flash[:notice] = "There is another piece you MUST move"
    # needs to be a legal move
    # if there is a piece next to you, you MUST eat it
    elsif !@game.required_moves(team).include?(from_coordinate + to_coordinate) && team === "black" && piece == "B" && validates_black_moves
      flash[:notice] = "That is not a legal move"
    elsif !@game.required_moves(team).include?(from_coordinate + to_coordinate) && team === "red" && piece == "R" && validates_red_moves
      flash[:notice] = "That is not a legal move"
    elsif piece.length == 2  && validates_red_moves && validates_black_moves
      flash[:notice] = "the king piece can move backwards"
    else
      #if a piece is eatten, the piece should be removed from the board
      if @game.required_moves(team) != []
        state[(from_row + to_row)/2][(from_column + to_column)/2] = nil
      end
      #moved piece is no longer at the from coordinate
      state[from_row][from_column] = nil
      #that moved piece is now at the to coordinate
      state[to_row][to_column] = piece


      @game.history_of_pieces << [from: from_coordinate, to: to_coordinate]
      # while to_coordinate is equal to the from coordiante of another piece to eat, it is tstill the players turn
      if team == "black" && @game.required_moves(team).include?(to_coordinate + [to_row + 2, to_column + 2]) || @game.required_moves(team).include?(to_coordinate + [to_row + 2, to_column - 2])
        flash[:notice] = "you can jump again!"
      elsif team == "black"
        @game.turn += 1
      end

      if piece == "B" && to_row == 7
        @game.state_of_piece[to_row][to_column] = "BK"
      elsif piece == "R" && to_row == 0
        @game.state_of_piece[to_row][to_column] = "RK"
      end
      #
      if team == "red" && @game.required_moves(team).include?(to_coordinate + [to_row - 2, to_column + 2]) || @game.required_moves(team).include?(to_coordinate + [to_row - 2, to_column - 2])
          flash[:notice] = "you can jump again!"
      elsif team == "red"
        @game.turn += 1
      end
      @game.save
      # redirect to the right place
    end
    render json: state
  end
end
