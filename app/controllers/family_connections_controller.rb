class FamilyConnectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_family_role!

  def create
    other = User.find_by(email: params[:email].to_s.strip.downcase)

    if other.nil?
      return redirect_to profile_path, alert: "No user found with that email."
    end

    if current_user.parent? && other.student?
      link(parent: current_user, student: other)
    elsif current_user.student? && other.parent?
      link(parent: other, student: current_user)
    else
      redirect_to profile_path, alert: "You can only link parents with students."
    end
  end

  def destroy
    connection = FamilyConnection.find(params[:id])

    unless connection.parent == current_user || connection.student == current_user
      return redirect_to profile_path, alert: "Not authorized."
    end

    connection.destroy
    redirect_to profile_path, notice: "Family connection removed."
  end

  private

  def link(parent:, student:)
    connection = FamilyConnection.find_or_initialize_by(parent: parent, student: student)

    if connection.new_record?
      connection.save!
      redirect_to profile_path, notice: "Request sent. The connection will be confirmed once the other person also links you."
    elsif connection.confirmed?
      redirect_to profile_path, notice: "You are already connected."
    else
      connection.update!(confirmed: true)
      redirect_to profile_path, notice: "Family connection confirmed!"
    end
  end

  def require_family_role!
    unless current_user.parent? || current_user.student?
      redirect_to profile_path, alert: "Only parents and students can create family connections."
    end
  end
end
