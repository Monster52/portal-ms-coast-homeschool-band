require 'rails_helper'

RSpec.describe "Comments", type: :request do
  let(:admin)        { create(:user, :admin) }
  let(:teacher)      { create(:user, :teacher) }
  let(:parent)       { create(:user, role: "parent") }
  let(:student)      { create(:user, role: "student") }
  let(:announcement) { create(:announcement, user: admin) }
  let!(:comment)     { create(:comment, announcement: announcement, user: parent) }

  describe "POST /announcements/:id/comments" do
    context "as any authenticated user" do
      before { sign_in student }

      it "creates a comment and redirects to the announcement" do
        expect {
          post announcement_comments_path(announcement),
               params: { comment: { body: "Great news!" } }
        }.to change(Comment, :count).by(1)
        expect(response).to redirect_to(announcement_path(announcement))
      end

      it "rejects a blank comment" do
        expect {
          post announcement_comments_path(announcement),
               params: { comment: { body: "" } }
        }.not_to change(Comment, :count)
        expect(response).to redirect_to(announcement_path(announcement))
      end
    end

    context "when not logged in" do
      it "redirects to sign in" do
        post announcement_comments_path(announcement), params: { comment: { body: "Hi" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "DELETE /announcements/:id/comments/:id" do
    context "as the comment author" do
      before { sign_in parent }

      it "deletes own comment" do
        expect {
          delete announcement_comment_path(announcement, comment)
        }.to change(Comment, :count).by(-1)
        expect(response).to redirect_to(announcement_path(announcement))
      end
    end

    context "as admin" do
      before { sign_in admin }

      it "can delete any comment" do
        expect {
          delete announcement_comment_path(announcement, comment)
        }.to change(Comment, :count).by(-1)
      end
    end

    context "as teacher" do
      before { sign_in teacher }

      it "can delete any comment" do
        expect {
          delete announcement_comment_path(announcement, comment)
        }.to change(Comment, :count).by(-1)
      end
    end

    context "as a different user with no special role" do
      before { sign_in student }

      it "cannot delete another user's comment" do
        expect {
          delete announcement_comment_path(announcement, comment)
        }.not_to change(Comment, :count)
        expect(response).to redirect_to(announcement_path(announcement))
      end
    end
  end
end
