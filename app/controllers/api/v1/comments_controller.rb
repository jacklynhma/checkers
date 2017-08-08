class Api::V1::CommentsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @game = Game.find(params[:game_id])
    @users = @game.users
    @comments = @game.comments
    @game.team_players

    user = current_user
    render json: {comments: @comments, game: @game, users: @users, user: user,
      redteamMembers: @game.team_players[1], blackteamMembers: @game.team_players[0]},
    adapter: :json
  end

  def create
    @game = Game.find(params[:game_id])
    @comment = @game.comments.new(comment_params)

    @comment.user = current_user
    current_user_team = current_user.gameplayers.find_by(game_id: @game.id)
    if @comment.save
      render json:{ comment: @comment, user: current_user, team: current_user_team}, adapter: :json
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end

end
