class AnnouncementsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_manager!, only: %i[new create edit update destroy]
  before_action :set_announcement, only: %i[show edit update destroy]

  def index
    @announcements = Announcement.includes(:user).order(created_at: :desc)
  end

  def show
    @comments = @announcement.comments.includes(:user).order(created_at: :asc)
    @comment  = Comment.new
  end

  def new
    @announcement = Announcement.new
  end

  def create
    @announcement = current_user.announcements.build(announcement_params)
    if @announcement.save
      redirect_to announcements_path, notice: "Announcement posted."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @announcement.update(announcement_params)
      redirect_to @announcement, notice: "Announcement updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @announcement.destroy
    redirect_to announcements_path, notice: "Announcement deleted."
  end

  private

  def set_announcement
    @announcement = Announcement.find(params[:id])
  end

  def announcement_params
    params.require(:announcement).permit(:title, :body)
  end

  def require_manager!
    redirect_to announcements_path, alert: "Not authorized." unless current_user.admin? || current_user.teacher?
  end
end
