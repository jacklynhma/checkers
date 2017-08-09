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
    @game.history_of_pieces = @game.history_of_pieces.reverse

    render json: {game: @game, team: team, winner: @game.winner, history: @game.history_of_pieces,
      redplayers: array_of_teams[1], currentuser: current_user, blackplayers: array_of_teams[0]
    },
      adapter: :json
  end

  def update
    @game = Game.find(params[:id])
    # make sure a piece deletes from a board before you put a piece on the board
    message = ""

    from_coordinate = [params[:coordinates][0], params[:coordinates][1]]
    to_coordinate = [params[:coordinates][2], params[:coordinates][3]]


    team = current_user.defining_team(@game)
    piece = @game.state_of_piece[from_coordinate[0]][from_coordinate[1]]
    # if params[:coordinates].length == 2 && @game.required_moves(team,
    #   from_coordinate) != []
    #   poss_mon = @game.required_moves(team, from_coordinate)
    # elsif params[:coordinates].length == 2 && @game.calculate_possible_moves(piece, params[:coordinates][0],params[:coordinates][1]) != []
    #   poss_mon = @game.calculate_possible_moves(piece, params[:coordinates][0],params[:coordinates][1])
    if @game.error_message(team, piece, from_coordinate, to_coordinate)
      message = @game.error_message(team, piece, from_coordinate, to_coordinate)
    else
      @game.steps_to_do_if_no_error_messages(from_coordinate, to_coordinate, piece, team)
      @game.save
    end
    render json: {piece: piece, game: @game, message: message, turn: @game.turn,
      winner: @game.winner, team: team,
      # possible: poss_mon
    }
  end
end
