class Conversation < ApplicationRecord
  has_many :conversation_participants, dependent: :destroy
  has_many :participants, through: :conversation_participants, source: :user
  has_many :messages, -> { order(created_at: :asc) }, dependent: :destroy

  def self.between(user_a, user_b)
    where(id: ConversationParticipant.where(user_id: user_a.id).select(:conversation_id))
      .where(id: ConversationParticipant.where(user_id: user_b.id).select(:conversation_id))
      .first
  end

  def other_participant(user)
    participants.where.not(id: user.id).first
  end

  def last_message
    messages.last
  end

  def unread_count_for(user)
    messages.where.not(user_id: user.id).where(read_at: nil).count
  end
end
