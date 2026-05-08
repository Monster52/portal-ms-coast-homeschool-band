require 'rails_helper'

RSpec.describe "Conversations", type: :request do
  let(:parent)  { create(:user, role: "parent") }
  let(:teacher) { create(:user, :teacher) }
  let(:student) { create(:user, role: "student") }

  let(:conversation) do
    create(:conversation, :between, user_a: parent, user_b: teacher)
  end

  describe "GET /conversations" do
    context "when logged in" do
      before { sign_in parent }

      it "returns 200" do
        get conversations_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "when not logged in" do
      it "redirects to sign in" do
        get conversations_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /conversations/:id" do
    before { sign_in parent }

    it "returns 200 for a participant" do
      get conversation_path(conversation)
      expect(response).to have_http_status(:ok)
    end

    it "returns 404 for a non-participant" do
      sign_in create(:user, role: "parent")
      get conversation_path(conversation)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /conversations/new" do
    context "as parent (can message)" do
      before { sign_in parent }

      it "returns 200" do
        get new_conversation_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "as student (cannot message)" do
      before { sign_in student }

      it "redirects away" do
        get new_conversation_path
        expect(response).to redirect_to(conversations_path)
      end
    end
  end

  describe "POST /conversations" do
    context "as parent" do
      before { sign_in parent }

      it "creates a new conversation with a message" do
        expect {
          post conversations_path, params: { recipient_id: teacher.id, body: "Hello!" }
        }.to change(Conversation, :count).by(1).and change(Message, :count).by(1)
      end

      it "reuses an existing conversation with the same person" do
        conversation # create it
        expect {
          post conversations_path, params: { recipient_id: teacher.id, body: "Again!" }
        }.not_to change(Conversation, :count)
        expect(Message.count).to eq(1)
      end

      it "rejects a blank message" do
        post conversations_path, params: { recipient_id: teacher.id, body: "" }
        expect(response).to redirect_to(new_conversation_path)
      end

      it "rejects missing recipient" do
        post conversations_path, params: { recipient_id: nil, body: "Hi" }
        expect(response).to redirect_to(new_conversation_path)
      end
    end

    context "as student" do
      before { sign_in student }

      it "does not create a conversation" do
        expect {
          post conversations_path, params: { recipient_id: teacher.id, body: "Hello" }
        }.not_to change(Conversation, :count)
      end
    end
  end

  describe "POST /conversations/:id/messages" do
    before { create(:message, conversation: conversation, sender: parent) }

    context "as teacher (can message)" do
      before { sign_in teacher }

      it "adds a message and redirects to the conversation" do
        expect {
          post conversation_messages_path(conversation), params: { body: "Reply!" }
        }.to change(Message, :count).by(1)
        expect(response).to redirect_to(conversation_path(conversation))
      end

      it "rejects a blank body" do
        post conversation_messages_path(conversation), params: { body: "" }
        expect(response).to redirect_to(conversation_path(conversation))
        expect(Message.count).to eq(1)
      end
    end

    context "as student" do
      before { sign_in student }

      it "returns 404 because student is not a participant" do
        post conversation_messages_path(conversation), params: { body: "Hi" }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
