class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @conversation = current_user.conversations.find(params[:conversation_id])

    unless current_user.can_message?
      return redirect_to @conversation, alert: "You cannot send messages."
    end

    message = @conversation.messages.build(body: params[:body].to_s.strip, sender: current_user)

    if message.save
      @conversation.touch
      redirect_to conversation_path(@conversation)
    else
      redirect_to conversation_path(@conversation), alert: "Message cannot be blank."
    end
  end
end
