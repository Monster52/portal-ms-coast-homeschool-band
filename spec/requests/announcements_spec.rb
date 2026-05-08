require 'rails_helper'

RSpec.describe "Announcements", type: :request do
  let(:admin)        { create(:user, :admin) }
  let(:teacher)      { create(:user, :teacher) }
  let(:regular_user) { create(:user) }
  let!(:announcement) { create(:announcement, user: admin) }

  describe "GET /announcements" do
    context "when logged in" do
      before { sign_in regular_user }

      it "returns 200" do
        get announcements_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "when not logged in" do
      it "redirects to sign in" do
        get announcements_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /announcements/:id" do
    before { sign_in regular_user }

    it "returns 200" do
      get announcement_path(announcement)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /announcements/new" do
    context "as admin" do
      before { sign_in admin }

      it "returns 200" do
        get new_announcement_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "as teacher" do
      before { sign_in teacher }

      it "returns 200" do
        get new_announcement_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "as parent or student" do
      before { sign_in regular_user }

      it "redirects away" do
        get new_announcement_path
        expect(response).to redirect_to(announcements_path)
      end
    end
  end

  describe "POST /announcements" do
    let(:valid_params) { { announcement: { title: "Test", body: "Hello everyone" } } }

    context "as admin" do
      before { sign_in admin }

      it "creates an announcement and redirects" do
        expect {
          post announcements_path, params: valid_params
        }.to change(Announcement, :count).by(1)
        expect(response).to redirect_to(announcements_path)
      end

      it "enqueues emails to all users on create" do
        create(:user)
        expect {
          post announcements_path, params: valid_params
        }.to have_enqueued_mail(AnnouncementMailer, :new_announcement).at_least(:once)
      end

      it "renders new with unprocessable_entity on blank title" do
        post announcements_path, params: { announcement: { title: "", body: "body" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "as teacher" do
      before { sign_in teacher }

      it "creates an announcement and redirects" do
        expect {
          post announcements_path, params: valid_params
        }.to change(Announcement, :count).by(1)
        expect(response).to redirect_to(announcements_path)
      end
    end

    context "as parent or student" do
      before { sign_in regular_user }

      it "does not create and redirects" do
        expect {
          post announcements_path, params: valid_params
        }.not_to change(Announcement, :count)
        expect(response).to redirect_to(announcements_path)
      end
    end
  end

  describe "PATCH /announcements/:id" do
    context "as admin" do
      before { sign_in admin }

      it "updates and redirects" do
        patch announcement_path(announcement), params: { announcement: { title: "Updated" } }
        expect(response).to redirect_to(announcement_path(announcement))
        expect(announcement.reload.title).to eq("Updated")
      end

      it "renders edit with unprocessable_entity on blank title" do
        patch announcement_path(announcement), params: { announcement: { title: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "as teacher" do
      before { sign_in teacher }

      it "updates and redirects" do
        patch announcement_path(announcement), params: { announcement: { title: "Teacher Update" } }
        expect(response).to redirect_to(announcement_path(announcement))
        expect(announcement.reload.title).to eq("Teacher Update")
      end
    end

    context "as parent or student" do
      before { sign_in regular_user }

      it "redirects without updating" do
        patch announcement_path(announcement), params: { announcement: { title: "Hack" } }
        expect(response).to redirect_to(announcements_path)
        expect(announcement.reload.title).not_to eq("Hack")
      end
    end
  end

  describe "DELETE /announcements/:id" do
    context "as admin" do
      before { sign_in admin }

      it "destroys and redirects" do
        expect {
          delete announcement_path(announcement)
        }.to change(Announcement, :count).by(-1)
        expect(response).to redirect_to(announcements_path)
      end
    end

    context "as teacher" do
      before { sign_in teacher }

      it "destroys and redirects" do
        expect {
          delete announcement_path(announcement)
        }.to change(Announcement, :count).by(-1)
        expect(response).to redirect_to(announcements_path)
      end
    end

    context "as parent or student" do
      before { sign_in regular_user }

      it "does not destroy and redirects" do
        expect {
          delete announcement_path(announcement)
        }.not_to change(Announcement, :count)
        expect(response).to redirect_to(announcements_path)
      end
    end
  end
end
