class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params[:session][:email].downcase
    if user&.authenticate params[:session][:password]
      login_activated_user user
    else
      flash.now[:danger] = t ".login_error"
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private
  def login user
    log_in user
    params[:session][:remember_me] == "1" ? remember(user) : forget(user)
    redirect_back_or user
  end

  def login_activated_user user
    if user.activated?
      login user
    else
      flash[:warning] = t ".required_activate_email"
      redirect_to root_url
    end
  end
end
