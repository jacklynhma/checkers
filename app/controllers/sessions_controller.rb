class SessionsController < ApplicationController
  def create

    begin
      # https://www.sitepoint.com/rails-authentication-oauth-2-0-omniauth/
      @user = User.from_omniauth(request.env['omniauth.auth'])
      session[:user_id] = @user.id
      flash[:success] = "Welcome, #{@user.name}"
    rescue
      flash[:warning] = "There was an error "
    end
    redirect_to root_path
  end

  private

end
