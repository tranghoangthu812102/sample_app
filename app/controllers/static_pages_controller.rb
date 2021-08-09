class StaticPagesController < ApplicationController
  def home
    return unless logged_in?

    @micropost = current_user.microposts.build
    @feed_items = User.feed(current_user.id).recent_posts.page params[:page]
  end

  def help; end

  def about; end

  def contact; end
end
