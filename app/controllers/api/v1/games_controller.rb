class Api::V1::GamesController < ApplicationController
  # skip_before_action :verify_authenticity_token
  def show
    render json: Game.find(params[:id]), adapter: :json
  end
end
