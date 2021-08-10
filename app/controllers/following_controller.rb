class FollowingController < ApplicationController
  before_action :load_user

  def index
    @title = t "following"
    @users = @user.following.page params[:page]
    render "users/show_follow"
  end
end
