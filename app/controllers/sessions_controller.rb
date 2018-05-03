class SessionsController < ApplicationController
  def create

    begin
      # https://www.sitepoint.com/rails-authentication-oauth-2-0-omniauth/
      @account = Account.from_omniauth(omniauth_hash, current_user)
      session[:user_id] = @user.id
      flash[:success] = "Thank you for connecting your Github"
    rescue
      flash[:warning] = "There was an error "
    end
    redirect_to root_path
  end

  private

  def omniauth_hash
    request.env['omniauth.auth']
  end
end
