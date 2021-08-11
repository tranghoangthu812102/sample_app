class FollowerController < ApplicationController
  before_action :load_user

  def index
    @title = t "follower"
    @users = @user.followers.page params[:page]
    render "users/show_follow"
  end
end
