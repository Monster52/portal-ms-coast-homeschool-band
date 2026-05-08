class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    if @user.parent?
      @connections = @user.student_connections.includes(:student).order(confirmed: :desc, created_at: :desc)
    elsif @user.student?
      @connections = @user.parent_connections.includes(:parent).order(confirmed: :desc, created_at: :desc)
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(profile_params)
      redirect_to profile_path, notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:first_name, :last_name, :avatar)
  end
end
