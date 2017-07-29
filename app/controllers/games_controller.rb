class GamesController < ApplicationController

  before_action :authorize_user, except: [:index, :show]
  def index
    @games = Game.all
  end

  def show
    @game = Game.find(params[:id])
  end

  def new
    @game = Game.new
  end

  # Assigning players to teams
  def join
    @game = Game.find(params[:id])
    if @game.gameplayers.where(team: "red").count.zero?
      @game.gameplayers.create(user: current_user, team: "red")
    elsif @game.gameplayers.where(team: "black").count.zero?
      @game.gameplayers.create(user: current_user, team: "black")
    end
    redirect_to @game
  end

  def resign
    @game = Game.find(params[:id])
    player = @game.gameplayers.find_by(user: current_user)
    if player.nil?
      flash[:notice] = "you are not part of this team"
    else
      player.destroy
    end
    redirect_to games_path
  end

  def create
    @game = Game.new(game_params)
    byebug
    @game.gameplayers.build(user: current_user, team: "black")
    if @game.save
      redirect_to game_path(@game.id)
    else
      render action: "new"
    end
  end

  def edit
    @game = Game.find(params[:id])
    render action: "edit"
  end

  # returns the row
  def row(position)
    position[0]
  end

  # returns the column
  def column(position)
    position[1]
  end

  def update
    @game = Game.find(params[:id])

    state = @game.state_of_piece

    # params[:coordinate][:from]
    # params[:coordinate][:to]

    # make sure a piece deletes from a board before you put a piece on the board
    turn = 1
    message = ""

  # do stuff to the state of game, like moving the pieces
  #delete the piece on the board
    from_coordinate = JSON.parse(params[:coordinate][:from])
    to_coordinate = JSON.parse(params[:coordinate][:to])
  # is it your turn
    to_column = column(to_coordinate)
    from_column = column(from_coordinate)
    from_row = row(from_coordinate)
    binding.pry
    if current_user.gameplayers.find_by(game_id: @game.id).present?
      team = current_user.gameplayers.find_by(game_id: @game.id).team
    end
    piece = state[from_row][from_column]
    right_neighboring_piece = state[from_column + 1][from_row + 1]

    if (!team === "black" && (turn % 2 === 1)) || (!team === "red" && (turn % 2 === 0))
      flash[:notice] = "It is not your turn!"
  #Does the piece you want to move exist?
    elsif piece.nil?
      flash[:notice] = "That piece does not exist"
  # is it the player's piece?
    elsif !((team === "black") && ((piece === "B") || (piece === "BK"))) || ((team === "red") && ((piece === "R") || (piece === "RK")))
    flash[:notice] = "This is not your piece"
  #make the piece move on the board
  # the move needs to within the bounds of the board
    elsif !((row(to_coordinate) <= 7) && (row(to_coordinate) >= 0))
      flash[:notice] = "You are off the board"
    elsif !((to_column <= 7) && (to_column >= 0))
      flash[:notice] = "You are off the board"
  # needs to be a legal move
# if there is a piece next to you, you MUST eat it
elsif while team === "black" && (right_neighboring_piece === "R" || right_neighboring_piece === "KR") && state[from_column + 2][from_row + 2] === nil


    elsif team === "black" &&  (((from_column + 1) != to_column) && ((from_column - 1) != to_column) || ((from_row + 1) != row(to_coordinate)))
      flash[:notice] = "That is not a legal move"
    elsif team === "red" && (((from_column + 1) != to_column) && ((from_column - 1) != to_column) || ((from_row - 1) != row(to_coordinate)))
      flash[:notice] = "That is not a legal move"
    else
      state[from_row][from_column] = nil
      state[row(to_coordinate)][to_column] = piece
      # allows it to move diagonally
      turn += 1
      @game.state_of_piece = state
      @game.history_of_pieces = JSON.parse(@game.history_of_pieces)
      @game.history_of_pieces.push(from: from_coordinate, to: to_coordinate)
      @game.save

      # redirect to the right place
    end
    redirect_to game_path(@game)
  end

private
  def game_params
    params.require(:game).permit(:name, :state_of_piece, :history_of_pieces)
  end

  def authorize_user
    if !user_signed_in?
      redirect_to new_user_session_path
      return false
    end
  end
end
