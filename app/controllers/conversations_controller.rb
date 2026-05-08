class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: %i[show]

  def index
    @conversations = current_user.conversations
      .includes(:participants, :messages)
      .order(updated_at: :desc)
  end

  def show
    @messages = @conversation.messages.includes(:sender)
    @message  = Message.new

    # Mark messages sent by the other person as read
    @conversation.messages
      .where.not(user_id: current_user.id)
      .where(read_at: nil)
      .update_all(read_at: Time.current)
  end

  def new
    redirect_to conversations_path, alert: "You cannot send messages." unless current_user.can_message?
    @recipient_options = User.where.not(id: current_user.id).order(:email)
  end

  def create
    unless current_user.can_message?
      return redirect_to conversations_path, alert: "You cannot send messages."
    end

    recipient = User.find_by(id: params[:recipient_id])
    unless recipient
      return redirect_to new_conversation_path, alert: "Please select a recipient."
    end

    if recipient == current_user
      return redirect_to new_conversation_path, alert: "You cannot message yourself."
    end

    body = params[:body].to_s.strip
    if body.blank?
      return redirect_to new_conversation_path, alert: "Message cannot be blank."
    end

    conversation = Conversation.between(current_user, recipient) ||
      Conversation.create!.tap do |c|
        c.conversation_participants.create!(user: current_user)
        c.conversation_participants.create!(user: recipient)
      end

    conversation.messages.create!(sender: current_user, body: body)
    conversation.touch

    redirect_to conversation_path(conversation)
  end

  private

  def set_conversation
    @conversation = current_user.conversations.find(params[:id])
  end
end
