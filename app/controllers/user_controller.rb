class UserController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      flash[:success] = t "success_signup"
      redirect_to @user
    else
      flash[:error] = t "fail_signup"
      render :new
    end
  end

  def show
    @user = User.find_by id: params[:id]
    return if @user

    flash[:error] = t "not_found"
    redirect_to root_path
  end

  private

  def user_params
    params.require(:user).permit User::PERMITTED
  end
end
