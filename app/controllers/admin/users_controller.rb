class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_user, only: %i[edit update destroy]

  def index
    @users = User.order(:role, :email).includes(:avatar_attachment)
  end

  def edit
  end

  def update
    if @user.update(admin_user_params)
      redirect_to admin_users_path, notice: "#{@user.email} updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      return redirect_to admin_users_path, alert: "You cannot delete your own account here."
    end

    @user.destroy
    redirect_to admin_users_path, notice: "#{@user.email} has been deleted."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def admin_user_params
    params.require(:user).permit(:first_name, :last_name, :email, :role, :admin)
  end
end
