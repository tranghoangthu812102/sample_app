class UsersController < ApplicationController
  before_action :load_user, except: %i(index new create)
  before_action :logged_in_user, except: %i(show create new)
  before_action :correct_user, only: %i(edit update destroy)
  before_action :admin?, only: :destroy

  def index
    @users = User.all.page params[:page]
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t ".check_email"
      redirect_to root_url
    else
      flash[:error] = t "fail_signup"
      render :new
    end
  end

  def show
    @microposts = @user.microposts.recent_posts.page params[:page]
  end

  def edit; end

  def update
    if @user.update user_params
      flash[:success] = t "profile_updated"
      redirect_to @user
    else
      flash[:danger] = t "fail_updated"
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t "success_deleted"
    else
      flash[:danger] = "fail_deleted"
    end
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit User::PERMITTED
  end

  def correct_user
    redirect_to root_url unless current_user? @user
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end

  def load_user
    @user = User.find params[:id]
  end
end
