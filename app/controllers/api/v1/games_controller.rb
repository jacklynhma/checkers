class Api::V1::CerealsController < ApplicationController
  # skip_before_action :verify_authenticity_token
  def index
    render json: Game.all, adapter: :json
  end
end
