class UsersController < ApplicationController
  before_action :authorize_user, only: [:index, :destroy]

  def show
    @user = User.find(params[:id])
  end

  def destroy
    user = User.find(params[:id])

    if user.destroy
      redirect_to users_path, notice: "User deleted."
    else
      redirect_to users_path, flash: { error: "User could not be deleted." }
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :profile_photo, :state_id, :city_id)
  end

  def authorize_user
    if !user_signed_in? || !current_user.admin?
      raise ActionController::RoutingError.new("Not Found")
    end
  end
end
