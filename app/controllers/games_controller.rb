class GamesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authorize_user, except: %i[index show]

  def index
    @games = Game.all
    @game = Game.new
  end

  def show
    @game = Game.find(params[:id])
  end

  # Assigning players to teams
  def join

    @game = Game.find(params[:id])
    if @game.gameplayers.where(team: "red").count <  @game.gameplayers.where(team: "black").count
      @game.gameplayers.create(user: current_user, team: "red")
    elsif @game.gameplayers.where(team: "black").count < @game.gameplayers.where(team: "red").count
      @game.gameplayers.create(user: current_user, team: "black")
    elsif @game.gameplayers.where(team: "black").count == @game.gameplayers.where(team: "red").count
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
    @game.gameplayers.build(user: current_user, team: "black")
    if @game.save
      redirect_to "/games/#{@game.id}"
    else
      render action: "new"
    end
  end

# def edit
#   @game = Game.find(params[:id])
#   render action: "edit"
# end


  # returns the row
   def row(position)
     position[0]
   end

   # returns the column
   def column(position)
     position[1]
   end


  private

  def game_params
    params.require(:game).permit(:name, :state_of_piece)
  end

  def authorize_user
    if !user_signed_in?
      redirect_to new_user_session_path
      false
    end
  end
end
