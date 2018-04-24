class GamesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authorize_user, except: %i[index show]

  def index
    @games = Game.all
    @game = Game.new
  end

  def edit
    @game = Game.find(params[:id])
    render action: "edit"
  end

  def create
    @game = Game.new(game_params)
    @game.gameplayers.build(user: current_user, team: "black")
    if @game.save
      redirect_to "/games/#{@game.id}"
    else
      render action: "new"
    end
  end

  # Assigning players to teams
  def join
    @game = Game.find(params[:id])
    @game.assign_team(current_user)
    redirect_to "/games/#{@game.id}"
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

  private

  def authorize_user
    if !user_signed_in?
      redirect_to new_user_session_path
      false
    end
  end
   # returns the column
  def column(position)
    position[1]
  end

  def game_params
    params.require(:game).permit(:name, :state_of_piece)
  end

  # returns the row
  def row(position)
   position[0]
  end
end
