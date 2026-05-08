require 'rails_helper'

RSpec.describe Conversation, type: :model do
  let(:parent)  { create(:user, role: "parent") }
  let(:teacher) { create(:user, :teacher) }
  let(:student) { create(:user, role: "student") }

  describe ".between" do
    it "finds an existing conversation between two users" do
      convo = create(:conversation, :between, user_a: parent, user_b: teacher)
      expect(Conversation.between(parent, teacher)).to eq(convo)
    end

    it "returns nil when no conversation exists" do
      expect(Conversation.between(parent, teacher)).to be_nil
    end
  end

  describe "#other_participant" do
    it "returns the participant who is not the given user" do
      convo = create(:conversation, :between, user_a: parent, user_b: teacher)
      expect(convo.other_participant(parent)).to eq(teacher)
      expect(convo.other_participant(teacher)).to eq(parent)
    end
  end

  describe "#unread_count_for" do
    it "counts messages from the other person that have no read_at" do
      convo = create(:conversation, :between, user_a: parent, user_b: teacher)
      create(:message, conversation: convo, sender: teacher, read_at: nil)
      create(:message, conversation: convo, sender: teacher, read_at: nil)
      create(:message, conversation: convo, sender: parent,  read_at: nil)
      expect(convo.unread_count_for(parent)).to eq(2)
    end
  end
end
