class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_announcement

  def create
    @comment = @announcement.comments.build(body: params[:comment][:body], user: current_user)
    if @comment.save
      redirect_to @announcement, notice: "Comment posted."
    else
      redirect_to @announcement, alert: "Comment cannot be blank."
    end
  end

  def destroy
    @comment = @announcement.comments.find(params[:id])
    unless can_delete_comment?(@comment)
      return redirect_to @announcement, alert: "Not authorized."
    end
    @comment.destroy
    redirect_to @announcement, notice: "Comment deleted."
  end

  private

  def set_announcement
    @announcement = Announcement.find(params[:announcement_id])
  end

  def can_delete_comment?(comment)
    current_user.admin? || current_user.teacher? || comment.user == current_user
  end
end
