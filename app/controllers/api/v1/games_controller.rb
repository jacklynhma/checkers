class Api::V1::GamesController < ApplicationController
  skip_before_action :verify_authenticity_token
  # before_action :authorize_user, except: %i[index show]

  def index
    render json: Game.all, adapter: :json
  end

  def show
    @game = Game.find(params[:id])
    team = "none"
    if current_user && current_user.playing?(@game)
      team = current_user.gameplayers.find_by(game_id: @game.id).team
    end
    array_of_teams = @game.team_players

    render json: {game: @game, team: team, winner: @game.winner,
      redplayers: array_of_teams[1], blackplayers: array_of_teams[0]},
      adapter: :json
  end

  def update

    @game = Game.find(params[:id])
    state = @game.state_of_piece
    # make sure a piece deletes from a board before you put a piece on the board
    message = ""

    from_coordinate = [params[:coordinates][0], params[:coordinates][1]]
    to_coordinate = [params[:coordinates][2], params[:coordinates][3]]
    to_column = params[:coordinates][3]
    from_column = params[:coordinates][1]
    from_row = params[:coordinates][0]
    to_row = params[:coordinates][2]

    team = current_user.defining_team(@game)
    piece = @game.state_of_piece[from_row][from_column]
    if @game.error_message(from_row, from_column, team, piece, to_row, to_column, from_coordinate, to_coordinate)
      message = @game.error_message(from_row, from_column, team, piece, to_row, to_column, from_coordinate, to_coordinate)
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
      @game.second_jump(team, to_row, from_row, to_coordinate)
      @game.becoming_king(piece, to_row, to_column)


      @game.save
      # redirect to the right place

    end
    render json: {game: @game, message: message, turn: @game.turn, winner: @game.winner, team: team}
  end
end
